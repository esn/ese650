%% Script for train all hmm model
clear all
close all
clc

%% Split entire dataset
num_train = 3;
num_valid = 2;
[train, valid, gesture_list] = split_data(num_train, num_valid);
train = process_imu(train);
valid = process_imu(valid);

%% Get all acceleration
imu_all = cat_data(train, gesture_list);

%% Scale data to zero mean and unit variance
mean_imu = mean(imu_all, 1);
std_imu = std(imu_all, 1, 1);
imu_all = scale_imu(imu_all, mean_imu, std_imu);

%% Kmeans
n_cluster = 7;
x_idx = 1:length(imu_all);
[idx, centroids] = kmeans(imu_all(:,1:3), n_cluster, ...
                          'emptyaction', 'singleton', 'Replicates', 5);
cluster_color = lines(n_cluster);
% Visualize all clusters
figure()
for j = 1:3
  subplot(3,1,j)
  hold on
  for i = 1:n_cluster
    plot(x_idx(idx == i), imu_all(idx == i, j), ...
         '.', 'Color', cluster_color(i,:))
  end
  hold off
end
drawnow

%% Train hmm
n_state = 4;
for i = 1:length(gesture_list)
  T = 0;
  for j = 1:3
    acc = train(i).data(j).imu_proc(:,1:3);
    T = T + length(acc);
    ind = clustering(acc, centroids);
    seqs{j} = ind;
  end
  [A_guess, B_guess] = init_model(n_state, n_cluster, T);
  [A{i}, B{i}] = hmmtrain(seqs, A_guess, B_guess);
  fprintf('Finish training model %s\n', gesture_list{i});
end

%% Test hmm
for i = 1:length(gesture_list)
  fprintf('Testing gesture: %s\n', gesture_list{i})
  for j = 1:num_train + num_valid
    if j <= num_train
      acc = train(i).data(j).imu_proc(:,1:3);
    else
      acc = valid(i).data(j-num_train).imu_proc(:,1:3);
    end
    ind = clustering(acc, centroids);
    for k = 1:length(gesture_list)
      [~, logpseq(k)] = hmmdecode(ind, A{k}, B{k});
      fprintf('%8.2f  ', logpseq(k));
    end
    [~, max_ind] = max(logpseq);
    fprintf(' %s\n', gesture_list{max_ind})
  end
end