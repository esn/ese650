%% Project4 main
clear all; close all; clc;
addpath(genpath('.'));
data_id = 22;
data = load_data(data_id);
data.imu.real_vals = raw2real(data.imu.vals);

%% Initialization
% Synchronize time
t_imu = data.imu.ts;
t_enc = data.enc.ts;
t_ldr = data.ldr.ts;
num_imu = length(t_imu);
num_enc = length(t_enc);
num_ldr = length(t_ldr);

t_start = t_enc(1);
t_enc_ind = 1;
t_imu_ind = find(t_imu > t_start, 1, 'first');
t_ldr_ind = find(t_ldr > t_start ,1, 'first');
t_end = min(t_enc(end), t_ldr(end));

% Initialize variables for saving ukf estimate
X = [1; 0; 0; 0; 0; 0; 0];
cnt_ukf_hist = 0;
eul_ukf_hist = zeros(3,num_imu);

% Initialize variables for saving mcl estiamte
S = [0; 0; 0];
cnt_mcl_hist = 0;
max_cnt = max(num_enc, num_ldr);
S_mcl_hist = zeros(3,max_cnt);

% Initialize map


%% Main loop
t = t_start;
t_step = 0.01;
mcl_motion = false;
mcl_measure = false;
while(1)
    % Motion model
    if t > t_enc(t_enc_ind)  
        fprintf('enc\t%d\n', t_enc_ind);
        t_enc_ind = t_enc_ind + 1;
        mcl_motion = true;
    end
    
    % Map correlation
    if  t > t_ldr(t_ldr_ind) 
        fprintf('ldr\t%d\n', t_ldr_ind);
        t_ldr_ind = t_ldr_ind + 1;
        mcl_measure = true;
    end
    
    % Ukf orientation estimation
    if t > t_imu(t_imu_ind)  
        fprintf('imu\t%d\n', t_imu_ind);
        imu = data.imu.real_vals(:,t_imu_ind);
        X = ukf(imu(1:3), imu(4:6), t_imu(t_imu_ind), true);
        t_imu_ind = t_imu_ind + 1;

        cnt_ukf_hist = cnt_ukf_hist + 1;
        rot_est = quat2dcm(quatconj(X(1:4)'));
        eul_est = wrb2rpy_xyz(rot_est);
        eul_ukf_hist(:,cnt_ukf_hist) = eul_est;
    end
    
    % MCL
    if mcl_motion && mcl_measure  
        fprintf('mcl\t%d\n', cnt_mcl_hist);
        mcl_motion = false;
        mcl_measure = false;
        cnt_mcl_hist = cnt_mcl_hist + 1;
        S_mcl_hist(:,cnt_mcl_hist) = S;
    end
    
    if (t > t_end) || (t_imu_ind > num_imu) || ...
       (t_enc_ind > num_enc) || (t_ldr_ind > num_ldr)
        disp('Finished.')
        break
    end
    t = t + t_step;
end

%% Final visualization
h_eul = figure('Name', 'Euler Angles');
eul_ukf_hist = fix_eul(eul_ukf_hist);
plot_state(h_eul, data.imu.ts(1:cnt_ukf_hist), ...
    eul_ukf_hist(:,1:cnt_ukf_hist), 'eul', 'est');
