clear all
close all
clc

gesture_list = {'circle', 'figure8', 'fish', 'hammer', 'pend', 'wave'};

% Filter parameters
n = 3;
Wc = 4;

train = struct;
valid = struct;
% Load imu data into a struct
for i = 1:length(gesture_list)
    for j = 1:4
        [imu, t] = load_imu(gesture_list{i}, j);
        imu_filt = filter_imu(imu, n, Wc);
        train(i).data(j).gesture = gesture_list{i};
        train(i).data(j).imu = imu;
        train(i).data(j).imu_filt = imu_filt;
        train(i).data(j).t   = t;
    end
    [imu, t] = load_imu(gesture_list{i}, j+1);
    imu_filt = filter_imu(imu, n, Wc);
    valid(i).data.gesture = gesture_list{i};
    valid(i).data.imu = imu;
    valid(i).data.imu_filt = imu_filt;
    valid(i).data.t = t;
end

save('data.mat', 'train', 'valid', 'gesture_list');