% Script for train all hmm model
clear all
close all
clc

% Split entire dataset
[train, valid, gesture_list] = split_data;

% Get all acceleration
acc_all = [];
for i = 1:length(gesture_list)
    % Concatenate all training data for current gesture
    imu = cat_data(train, gesture_list(i));
    acc = imu(:,1:3);
    % filter with 4th oder butterworth and cutoff frequency of 4hz
%     acc = filter_imu(acc);
    % down sample by 5
%     acc = down_sample(acc);
    acc_all = [acc_all; acc];
end

% Get max and min acc after zero mean and unit variance
mean_acc = mean(acc_all, 1);
std_acc = std(acc_all, 1, 1);
acc_all = bsxfun(@minus, acc_all, mean_acc);
acc_all = bsxfun(@rdivide, acc_all, std_acc);
max_acc = max(acc_all);
min_acc = min(acc_all);

%% Generate bin ranges for quantization
num_quant = 8;
bin_ranges = zeros(num_quant+1, 3);
for i = 1:3
    bin_ranges(:,i) = linspace(min_acc(i), max_acc(i), num_quant+1);
end

obs_ind_all = [];
for i = 1:length(gesture_list)
    % Concatenate all training data for current gesture
    imu = cat_data(train, gesture_list(i));
    acc = imu(:,1:3);
    % filter with 4th oder butterworth and cutoff frequency of 4hz
%     acc = filter_imu(imu(:,1:3));
    % down sample by 5
%     acc = down_sample(acc);
    acc = bsxfun(@minus, acc, mean_acc);
    acc = bsxfun(@rdivide, acc, std_acc);
    obs_sub = zeros(size(acc));
    for j = 1:3
        [~, ind] = histc(acc(:,j), bin_ranges(:,j));
        obs_sub(:,j) = ind;
    end
    obs_sub(obs_sub > num_quant) = num_quant;
    obs_ind =sub2ind(num_quant*ones(1,3), obs_sub(:,1), obs_sub(:,2), obs_sub(:,3));
    obs_ind_all = [obs_ind_all; obs_ind];
end
