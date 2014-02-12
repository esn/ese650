clear all; close all; clc
addpath(genpath('./'))
addpath(genpath('../'))

%% Select dataset
data_id = 1;

% Load corresponding dataset
load(sprintf('../imu/imuRaw%d.mat', data_id));
imu_t = ts;
acc_raw = vals(1:3,:);
omg_raw = vals([5 6 4], :);
imu_raw = [acc_raw; omg_raw];
load(sprintf('../vicon/viconRot%d.mat', data_id));
vic_t = ts;
vic_rot = rots;

% Convert to physical unit
acc_real = raw2real(acc_raw, 'acc');
omg_real = raw2real(omg_raw, 'omg');

%% UKF
n_data = length(imu_t);
for k = 1:n_data
    t = imu_t(k);
    acc = acc_real(:,k);
    omg = omg_real(:,k);
    
    % Initialize UKF
    if k == 1
        quat0 = [1; 0; 0; 0];
        omg0  = omg;
        x = [quat0; omg0]; % state vector x, 7x1
        P = diag(0.01*ones(1,7)); % state covariance P, 7x7
        pt = t; % previous time
    else
        dt = t - pt; % delta t
        pt = t;
        
        alpha_d = norm(omg,2) * dt;
        e_d = omg / norm(omg,2);
    end
end