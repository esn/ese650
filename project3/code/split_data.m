function [train, valid, gesture_list] = split_data( num_train )
gesture_list = {'circle', 'figure8', 'fish', 'hammer', 'pend', 'wave'};
if nargin < 1, num_train = 3; end
num_valid = 5 - num_train;

% Filter parameters
n = 3;
Wc = 4;

train = struct;
valid = struct;
% Load imu data into a struct
for i = 1:length(gesture_list)
    % Gather train data
    for j = 1:num_train
        [imu, t] = load_imu(gesture_list{i}, j);
        train(i).data(j).gesture = gesture_list{i};
        train(i).data(j).imu = imu;
        train(i).data(j).t   = t;
    end
    % Gather valid data
    for j = 1:num_valid
        [imu, t] = load_imu(gesture_list{i}, j+num_train);
        valid(i).data(j).gesture = gesture_list{i};
        valid(i).data(j).imu = imu;
        valid(i).data(j).t = t;
    end
end

save('data.mat', 'train', 'valid', 'gesture_list');
end