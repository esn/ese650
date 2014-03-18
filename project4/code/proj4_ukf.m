clear all; close all; clc;
addpath(genpath('.'))
% Load data
data_id = 23;
data = load_data(data_id);

% Convert raw imu readings to real values
data.imu.vals = raw2real(data.imu.vals);

%% Main loop
num_data = length(data.imu.ts);
X_hist = zeros(7, num_data);
Z_hist = zeros(3, num_data);
for i = 1:num_data
    imu = data.imu.vals(:,i);
    t = data.imu.ts(i);
    [X, Z] = ukf(imu(1:3), imu(4:6), t);
    
    X_hist(:,i) = X;
    Z_hist(:,i) = Z;
    fprintf('\b\b\b\b\b%05d', i);
end

%% Visualize
rot_est = quat2dcm(quatconj(X_hist(1:4,:)'));
eul_est = vicon2rpy(rot_est);
eul_est = fix_yaw(eul_est);
h_eul = figure();
plot_state(h_eul, data.imu.ts, eul_est, 'eul', 'est');
h_mea = figure();
plot_state(h_mea, data.imu.ts, data.imu.vals(1:3,:), 'acc', 'mea');
plot_state(h_mea, data.imu.ts, Z_hist, 'acc', 'est');