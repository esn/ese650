clear all; close all; clc
addpath(genpath('./'))
addpath(genpath('../'))

%% Select dataset
data_id = 1;

% Load corresponding dataset
load(sprintf('../imu/imuRaw%d.mat', data_id));
% load(sprintf('../vicon/viconRot%d.mat', data_id));