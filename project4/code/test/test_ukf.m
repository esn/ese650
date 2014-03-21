clear all; close all; clc;
addpath(genpath('.'))
% Load data
data_id = 23;
data = load_data(data_id);

% Convert raw imu readings to real values
data.imu.real_vals = raw2real(data.imu.vals);

%% Main loop
num_imu = length(data.imu.ts);
X_hist = zeros(7, num_imu);
Z_hist = zeros(3, num_imu);
for i = 1:num_imu
    imu = data.imu.real_vals(:,i);
    t = data.imu.ts(i);
    [X, Z] = ukf(imu(1:3), imu(4:6), t, false);
    
    X_hist(:,i) = X;
    Z_hist(:,i) = Z;
    fprintf('\b\b\b\b\b%05d', i);
end
clear functions
num_imu = length(data.imu.ts);
X_hist1 = zeros(7, num_imu);
Z_hist1 = zeros(3, num_imu);
for i = 1:num_imu
    imu = data.imu.real_vals(:,i);
    t = data.imu.ts(i);
    [X, Z] = ukf(imu(1:3), imu(4:6), t, true);
    
    X_hist1(:,i) = X;
    Z_hist1(:,i) = Z;
    fprintf('\b\b\b\b\b%05d', i);
end

%% Visualize
rot_est = quat2dcm(quatconj(X_hist(1:4,:)'));
eul_est = rots2rpy(rot_est);
eul_est = fix_eul(eul_est);
h_eul = figure();
plot_state(h_eul, data.imu.ts, eul_est, 'eul', 'est');
h_mea = figure();
plot_state(h_mea, data.imu.ts, data.imu.real_vals(1:3,:), 'acc', 'mea');
plot_state(h_mea, data.imu.ts, Z_hist, 'acc', 'est');


rot_est1 = quat2dcm(quatconj(X_hist1(1:4,:)'));
eul_est1 = rots2rpy(rot_est1);
eul_est1 = fix_eul(eul_est1);
plot_state(h_eul, data.imu.ts, eul_est1, 'eul', 'vic');
plot_state(h_mea, data.imu.ts, Z_hist1, 'acc', 'vic');