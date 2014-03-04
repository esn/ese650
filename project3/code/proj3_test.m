%% Test script for project 3
clear all;
close all;
clc;

%% Load data
test_path = '../../test';
gesture_list = {'final'};
train_gesture_list = {'circle', 'figure8', 'fish', 'hammer', 'pend', 'wave'};
test = get_data(test_path, gesture_list, 0);
test = process_imu(test);

%% Load model
load('model.mat')

%% Test
for i = 1:length(gesture_list)
  fprintf('Testing gesture: %s\n', gesture_list{i})
  for j = 1:length(test(i).data)
    imu = test(i).data(j).imu_proc;
    imu = scale_imu(imu, mean_imu, std_imu);
    
    X = imu(:,1:3);
    ind = clustering(X, C);
    logpseq = zeros(1, length(gesture_list));
    for k = 1:length(train_gesture_list)
      [~, logpseq(k)] = hmm_decode(ind, A{k}, B{k});
      fprintf('%8.2f  ', logpseq(k));
    end
    [~, max_ind] = max(logpseq);
    fprintf(' %s/%s\n', train_gesture_list{max_ind}, gesture_list{i})
  end
end