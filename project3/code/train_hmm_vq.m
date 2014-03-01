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
    acc = filter_imu(acc);
    % down sample by 5
    acc = down_sample(acc);
    acc_all = [acc_all; acc];
end

% Get max and min acc after zero mean and unit variance
mean_acc = mean(acc_all, 1);
std_acc = std(acc_all, 1, 1);
acc_all = scale_imu(acc_all, mean_acc, std_acc);
max_acc = max(acc_all);
min_acc = min(acc_all);

%% Generate bin ranges for quantization
n_quant = 8;
n_state = 8;
T = 0;

% Kmeans Cluster
for i = 1:1%length(gesture_list)
    % Get training observation sequence
    for j = 1:3
        acc = train(i).data(j).imu(:,1:3);
        T = T + length(acc);
        % filter with 4th oder butterworth and cutoff frequency of 4hz
        acc = filter_imu(acc);
        % down sample by 5
        acc = down_sample(acc);
        % scale to zero mean and unit variance
        acc = scale_imu(acc, mean_acc, std_acc);
        % generate observation symbols using vector quantization
        ind = quantization(acc, min_acc, max_acc, n_quant);
        seqs{j} = ind;
    end
    % Initialize transition and emission matrix
    T = T/3;
    d = T/n_state;
    a_ii = 1 - 1/d;
    A_guess = eye(n_state) * a_ii;
    for m = 1:n_state
        for n = 1:n_state
            if (n - m) == 1
                A_guess(m,n) = 1 - a_ii;
            end
        end
    end
    A_guess(n_state,1) = 1 - a_ii;
    B_guess = ones(n_state, n_quant^3)*1/n_quant^3;
    [A{i}, B{i}] = hmmtrain(seqs, A_guess, B_guess, 'Verbose', true);
end

%%
acc = valid(5).data(1).imu(:,1:3);
acc = filter_imu(acc);
acc = down_sample(acc);
acc = scale_imu(acc, mean_acc, std_acc);
ind = quantization(acc, min_acc, max_acc, n_quant);
[pstate, logpseq] = hmmdecode(ind, A{1}, B{1});