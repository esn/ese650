%% Script for train all hmm model
clear all
close all
clc

%% Parameters
n_train = 2;
n_valid = 3;
n_state = 2;
n_cluster = 6;
use_gyro = false;

%% Split entire dataset
[train, valid, gesture_list] = split_data(n_train, n_valid);
train = process_imu(train);
valid = process_imu(valid);

%% Get all acceleration
imu_all = cat_data(train, gesture_list);

%% Scale data to zero mean and unit variance
mean_imu = mean(imu_all, 1);
std_imu = std(imu_all, 1, 1);
imu_all = scale_imu(imu_all, mean_imu, std_imu);

%% Kmeans
x_idx = 1:length(imu_all);
if use_gyro
  [idx, centroids] = kmeans(imu_all, n_cluster, ...
                            'emptyaction', 'singleton', 'Replicates', 5);
else
  [idx, centroids] = kmeans(imu_all(:,1:3), n_cluster, ...
                            'emptyaction', 'singleton', 'Replicates', 5);
end
cluster_color = lines(n_cluster);
% Visualize all clusters seperate
labels = {'ax', 'ay', 'az'};
figure()
for j = 1:3
  subplot(3,1,j); hold on
  for i = 1:n_cluster
    title(labels{j})
    plot(x_idx(idx == i), imu_all(idx == i, j), ...
         '.', 'Color', cluster_color(i,:))
    grid on
    axis tight
    set(gca, 'Box', 'On')
  end
  hold off
end
% Visualize all clusters 3d
figure(); hold on
for i = 1:n_cluster
  plot3(imu_all(idx == i, 1), ...
        imu_all(idx == i, 2), ...
        imu_all(idx == i, 3), ...
        '.', 'Color', cluster_color(i,:))
end
axis equal; grid on; hold off; drawnow

%% Train hmm
A = cell(1,length(gesture_list));
B = cell(1,length(gesture_list));
for i = 1:length(gesture_list)
  T = 0;
  seqs = cell(1,n_train);
  for j = 1:n_train
    imu = train(i).data(j).imu_proc;
    imu = scale_imu(imu, mean_imu, std_imu);
    if use_gyro
      X = imu;
    else
      X = imu(:,1:3);
    end
    T = T + length(X);
    ind = clustering(X, centroids);
    seqs{j} = ind;
  end
  [A_guess, B_guess] = init_model(n_state, n_cluster, T/n_train);
  [A{i}, B{i}] = hmmtrain(seqs, A_guess, B_guess, 'Verbose', true);
  fprintf('Finish training model %s\n', gesture_list{i});
end

%% Test hmm
for i = 1:length(gesture_list)
  fprintf('Testing gesture: %s\n', gesture_list{i})
  for j = 1:n_train + n_valid
    if j <= n_train
      imu = train(i).data(j).imu_proc;
    else
      imu = valid(i).data(j-n_train).imu_proc;
    end
    imu = scale_imu(imu, mean_imu, std_imu);
    if use_gyro
      X = imu;
    else
      X = imu(:,1:3);
    end
    ind = clustering(X, centroids);
    logpseq = zeros(1, length(gesture_list));
    for k = 1:length(gesture_list)
      [~, logpseq(k)] = hmmdecode(ind, A{k}, B{k});
      fprintf('%8.2f  ', logpseq(k));
    end
    [~, max_ind] = max(logpseq);
    fprintf(' %s/%s\n', gesture_list{max_ind}, gesture_list{i})
  end
end