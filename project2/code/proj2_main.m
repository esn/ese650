% clear all; close all; clc
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
acc_real = raw2real(acc_raw, 'acc');
omg_real = raw2real(omg_raw, 'omg');

%% UKF
% Debug
X_hist = zeros(7, length(imu_t));
% Main loop
n_data = length(imu_t);
for k = 1:n_data
    t = imu_t(k);
    acc = acc_real(:,k);
    omg = omg_real(:,k);

    % Initialize UKF
    if k == 1
        pt = t; % previous time
        X0 = [[1;0;0;0]; omg];       % state vector X, 7x1
        X  = X0;
        P  = diag([[1e-4, 1e-4, 1e-4], [0, 0, 0]]);  % state covariance P, 6x6
        Q  = diag(0.0001*ones(1,6));  % process covariance Q, 6x6
        R  = diag([[0.1, 0.1, 0.1], [1e-4, 1e-4, 1e-4]]);  % measurement covariance R, 6x6
        % Generate ukf weights
        n = 6; % or 7?
        alpha = 0.7; % small value between 0 and 1
        beta = 2; % optimal for gaussian noise
        kappa = 0; % or 3 - n
        [Wm, Wc, C] = ukf_weight(n, alpha, beta, kappa); % C = gamma^2

        X_hist(:,1) = X0;
    else
        dt  = t - pt; % delta t
        pt  = t;

        % Generate sigma points Xi
        Xs  = ukf_quat_sigma(X, P, Q, C);
        % Transform sigma points Xi to get Yi through process model
        Ys  = ukf_process_ut(Xs, dt);
        % Use barycentric mean with renormalization to calculate
        % quaternion mean
        Y   = ukf_process_mean(Ys, Wm);
        % Calculate a priori state vector covariance
        [P, Wy] = ukf_apriori_state_cov(Ys, Y, Wc);
        % Transform sigma points Yi to get Zi through measurement model
        Zs  = ukf_measurement_ut(Ys);
        % Use barycentric mean to calculate measuremtn mean
        Z   = sum(bsxfun(@times, Zs, Wm), 2);
        % Calculate measurement estimate covariance
        Wz  = bsxfun(@minus, Zs, Z);
        Pzz = Wz * diag(Wc) * Wz';
        % Calculate cross correlation matrix
        Pxz = Wy * diag(Wc) * Wz';
        Pvv = Pzz + R;
        % Calculate Kalman gain
        K   = Pxz * inv(Pvv);
        % Calculate innovation
        V   = [acc; omg] - Z;
        % Update state and covariance
        X   = ukf_kalman_update(Y, V, K);
        P   = P - K * Pvv * K';
        % Save state
        X_hist(:,k) = X;
    end
end

%% Compare results
eul_est = vicon2rpy(quat2dcm(quatconj(X_hist(1:4,:)')));
eul_vic = vicon2rpy(vic_rot);
figure()
for i = 1:3
    subplot(3,1,i)
    hold on
    plot(vic_t - min(imu_t(1), vic_t(1)), eul_vic(i,:), 'r', 'LineWidth', 2);
    plot(imu_t - min(imu_t(1), vic_t(1)), eul_est(i,:), 'b', 'LineWidth', 2);
    hold off
    grid on
    axis tight
end
