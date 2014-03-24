%% Project4 main
clear all; close all; clc;
addpath(genpath('.'));
data_id = 21;
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
wrb_est = quat2dcm(quatconj(X(1:4)'));
eul_est = wrb2rpy_xyz(wrb_est);
k_ukf_hist = 0;
eul_ukf_hist = zeros(3,num_imu);
t_ukf_hist = zeros(1,num_imu);

% Initialize all classes
car = MagicRobot();
map = GridMap(30, 0.1, 0.9999);
mcl = MonteCarlo(20);
ldr = Hokuyo(data.ldr.angles);
% Initialize map


%% Main loop
t = t_start;
t_step = 0.005;

while(1)
    % sample model
    if t > t_enc(enc_ind)
        %fprintf('enc\t%d\n', enc_ind);
        enc = data.enc.counts(:,enc_ind);

        % Calculate odometry
        car.enc2odom(enc);
        % Sample motion model
        mcl.sample_motion_model(car.u, car.a);

        enc_ind = enc_ind + 1;
    end

    % Map correlation
    if  t > t_ldr(ldr_ind)
        %fprintf('ldr\t%d\n', ldr_ind);
        range = data.ldr.ranges(:,ldr_ind);

        % store range
        ldr.store_range(range);
        % Measurement model
        mcl.measurement_model(map.map, map.xy_bound, map.res, ldr, eul_est);
        % Transform laser into world frame
        car.update_state(mcl.best_p);
        car.append_hist();
        ldr.transform_range(car.s, wrb_est);
        ldr.prune_range();
        
        ldr_ind = ldr_ind + 1;
    end

    % Ukf orientation estimation
    if t > t_imu(imu_ind)
        %fprintf('imu\t%d\n', imu_ind);
        imu = data.imu.real_vals(:,imu_ind);
        X = ukf(imu(1:3), imu(4:6), t_imu(imu_ind), true);
        imu_ind = imu_ind + 1;

        k_ukf_hist = k_ukf_hist + 1;
        wrb_est = quat2dcm(quatconj(X(1:4)'));
        eul_est = wrb2rpy_xyz(wrb_est);
        eul_ukf_hist(:,k_ukf_hist) = eul_est;
        t_ukf_hist(:,k_ukf_hist) = t;
    end

    % MCL
    if mcl.motion && mcl.measure
        %fprintf('mcl\n');
        % Resample to get new particles and new weights
        mcl.resample();
        % Update map, car.s will be replaced by mcl.best_p
        map.update_map(car.s, ldr.p_range, ldr.dz, t);

        % Visualization
        map.plot_map();
        map.plot_car('bo', 'MarkerSize', 8);
        map.plot_traj('m');
        map.plot_lidar(ldr.p_range, 'g.');
        map.plot_particle(mcl.p, 'r.');
        
        % Reset flags
    end

    if (t > t_end) || (imu_ind > num_imu) || ...
       (enc_ind > num_enc) || (ldr_ind > num_ldr)
        disp('Finished.')
        break
    end
    t = t + t_step;
    drawnow
end

map.truncate_hist();

%% Final visualization
h_eul = figure('Name', 'Euler Angles');
eul_ukf_hist = fix_eul(eul_ukf_hist);
plot_state(h_eul, data.imu.ts(1:k_ukf_hist), ...
    eul_ukf_hist(:,1:k_ukf_hist), 'eul', 'est');
figure('Name', 'Yaw')
hold on
plot(t_ukf_hist, eul_ukf_hist(3,:), 'r');
plot(map.t_hist, map.s_hist(3,:), 'b');
hold off
axis tight
grid on
set(gca, 'Box', 'On')
