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
enc_ind = 1;
imu_ind = find(t_imu > t_start, 1, 'first');
ldr_ind = find(t_ldr > t_start ,1, 'first');
t_end = min(t_enc(end), t_ldr(end));

% Initialize variables for saving ukf estimate
X = [1; 0; 0; 0; 0; 0; 0];
cnt_ukf_hist = 0;
eul_ukf_hist = zeros(3,num_imu);
cnt_mcl_hist = 0;
% Initialize all classes
car = MagicRobot();

% Initialize map


%% Main loop
t = t_start;
t_step = 0.01;
mcl_motion = false;
mcl_measure = false;

while(1)
    % sample model
    if t > t_enc(enc_ind)  
        fprintf('enc\t%d\n', enc_ind);
        
        
        enc_ind = enc_ind + 1;
        mcl_motion = true;
    end
    
    % Map correlation
    if  t > t_ldr(ldr_ind) 
        fprintf('ldr\t%d\n', ldr_ind);
        
        
        ldr_ind = ldr_ind + 1;
        mcl_measure = true;
    end
    
    % Ukf orientation estimation
    if t > t_imu(imu_ind)  
        fprintf('imu\t%d\n', imu_ind);
        imu = data.imu.real_vals(:,imu_ind);
        X = ukf(imu(1:3), imu(4:6), t_imu(imu_ind), true);
        
        imu_ind = imu_ind + 1;
        
        cnt_ukf_hist = cnt_ukf_hist + 1;
        wrb_est = quat2dcm(quatconj(X(1:4)'));
        eul_est = wrb2rpy_xyz(wrb_est);
        eul_ukf_hist(:,cnt_ukf_hist) = eul_est;
    end
    
    % MCL
    if mcl_motion && mcl_measure  
        fprintf('mcl\t%d\n', cnt_mcl_hist);
        mcl_motion = false;
        mcl_measure = false;
        cnt_mcl_hist = cnt_mcl_hist + 1;
    end
    
    if (t > t_end) || (imu_ind > num_imu) || ...
       (enc_ind > num_enc) || (ldr_ind > num_ldr)
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
