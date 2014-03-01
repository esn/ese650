%% Script for train all hmm model
clear all
close all
clc

%% Split entire dataset
num_train = 3;
num_valid = 2;
[train, valid, gesture_list] = split_data(num_train, num_valid);

%% Get all acceleration
acc_all = [];
for i = 1:length(gesture_list)
  % Concatenate all training data for current gesture
  imu = cat_data(train, gesture_list(i));
  acc = imu(:,1:3);
  % filter with 4th oder butterworth and cutoff frequency of 4hz
  acc = filter_imu(acc);
  % down sample by 5
  acc = down_sample(acc);
  acc_all = [acc_all; acc];
end

%% Scale data to zero mean and unit variance
mean_acc = mean(acc_all, 1);
std_acc = std(acc_all, 1, 1);
acc_all = scale_imu(acc_all, mean_acc, std_acc);
plot_imu([], acc_all, [], 'acc', 'b');

%% Run kmeans on the entire acceleration data
n_cluster = 8;
x_idx = 1:length(acc_all);
[idx, centroids] = ...
  kmeans(acc_all, n_cluster, 'emptyaction', 'singleton', 'Replicates', 5);
cluster_color = lines(n_cluster);
figure()
for j = 1:3
  subplot(3,1,j)
  hold on
  for i = 1:n_cluster
    plot(x_idx(idx == i), acc_all(idx == i, j), '.', 'Color', ...
         cluster_color(i,:))
  end
  hold off
end
drawnow

%% Convert observation to observation symbols
n_state = 6;
T = 0;
for i = 1:length(gesture_list)
  for j = 1:3
    acc = train(i).data(j).imu(:,1:3);
    T = T + length(acc);
    % filter with 4th oder butterworth and cutoff frequency of 4hz
    acc = filter_imu(acc);
    % down sample by 5
    acc = down_sample(acc);
    % scale to zero mean and unit variance
    acc = scale_imu(acc, mean_acc, std_acc);
    % Generate observation symbols using clusters
    ind = clustering(acc, centroids);
    seqs{j} = ind;
  end
  [A_guess, B_guess] = init_model(n_state, n_cluster, T);
  [A{i}, B{i}] = hmmtrain(seqs, A_guess, B_guess);
end

%% Test on each model
for i = 1:length(gesture_list)
  fprintf('Testing gesture: %s\n', gesture_list{i})
  for j = 1:num_train + num_valid
    if j <= num_train
      acc = train(i).data(j).imu(:,1:3);
    else
      acc = valid(i).data(j-num_train).imu(:,1:3);
    end
    acc = filter_imu(acc);
    acc = down_sample(acc);
    acc = scale_imu(acc, mean_acc, std_acc);
    ind = clustering(acc, centroids);
    for k = 1:length(gesture_list)
      [~, logpseq] = hmmdecode(ind, A{k}, B{k});
      fprintf('%4.2f\t\t', logpseq);
    end
    fprintf('\n')
  end

end