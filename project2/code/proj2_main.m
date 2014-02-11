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
acc_scale = 0.0106*[-1; -1; 1];
acc_bias  = 1023/2;
acc = bsxfun(@times, acc_bias - acc_raw, acc_scale);

omg_scale = 0.0171;
omg_bias  = [374; 375; 370]; % [bwx, bwy, bwz]
omg = bsxfun(@minus, omg_raw, omg_bias) * omg_scale;

%%