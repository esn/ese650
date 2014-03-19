clear all; close all; clc
addpath(genpath('./'))
addpath(genpath('../'))

%% Select dataset
data_id = 8;
% Load corresponding dataset
load(sprintf('../imu/imuRaw%d.mat', data_id));
% load(sprintf('../Project2_Test/imu/imuRaw%d.mat', data_id));
t_imu   = ts;
acc_raw = vals(1:3,:);
omg_raw = vals(4:6,:);
load(sprintf('../vicon/viconRot%d.mat', data_id));
% load(sprintf('../Project2_Test/vicon/viconRot%d.mat', data_id));
rot_vic = rots;
t_vic = ts;
% Convert to physical unit
acc_real = raw2real(acc_raw, 'acc');
omg_real = raw2real(omg_raw, 'omg');

%% UKF
% Debug
n_data = length(t_imu);
X_hist = zeros(7, n_data);
Z_hist = zeros(3, n_data);
% Main loop
for i = 1:n_data
    t = t_imu(i);
    acc = acc_real(:,i);
    omg = omg_real(:,i);
    [X, Z] = ukf(acc, omg, t, true);
    % Save state
    X_hist(:,i) = X;
    Z_hist(:,i) = Z;
    fprintf('\b\b\b\b\b%05d', i);
end

%% Compare results
rot_est = quat2dcm(quatconj(X_hist(1:4,:)'));
eul_est = vicon2rpy(rot_est);
eul_est = fix_eul(eul_est);
eul_vic = vicon2rpy(rot_vic);
eul_vic = fix_eul(eul_vic);
h_eul = figure();
plot_state(h_eul, t_vic - min(t_imu(1), t_vic(1)), eul_vic, 'eul', 'vic');
plot_state(h_eul, t_imu - min(t_imu(1), t_vic(1)), eul_est, 'eul', 'est');
h_mea = figure();
plot_state(h_mea, t_imu - min(t_imu(1), t_vic(1)), acc_real, 'acc', 'mea');
plot_state(h_mea, t_imu - min(t_imu(1), t_vic(1)), Z_hist, 'acc', 'est');