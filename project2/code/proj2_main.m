% clear all; close all; clc
addpath(genpath('./'))
addpath(genpath('../'))

%% Select dataset
data_id = 8;
correction = true;
anim = true;
% Load corresponding dataset
load(sprintf('../imu/imuRaw%d.mat', data_id));
t_imu = ts;
acc_raw = vals(1:3,:);
omg_raw = vals([5 6 4], :);
imu_raw = [acc_raw; omg_raw];
load(sprintf('../vicon/viconRot%d.mat', data_id));
t_vic   = ts;
rot_vic = rots;

% Convert to physical unit
acc_real = raw2real(acc_raw, 'acc');
omg_real = raw2real(omg_raw, 'omg');

%% UKF
% Debug
X_hist = zeros(7, length(t_imu));
Z_hist = zeros(3, length(t_imu));
% Main loop
n_data = length(t_imu);
for k = 1:n_data
    t = t_imu(k);
    acc = acc_real(:,k);
    omg = omg_real(:,k);
    
    % Initialize UKF
    if k == 1
        % Initialize state vector and covariance matrices
        pt  = t; % previous time
        X0  = [[1;0;0;0]; [0;0;0]];   % state vector X, 7x1
        X   = X0;
        P   = diag([ones(3,1)*0.001; ones(3,1)*0.001]); % state covariance P, 6x6
        Q   = diag([ones(3,1)*0.0001; ones(3,1)*0.00001]);  % process covariance Q, 6x6
        R   = diag(ones(3,1)*0.115);  % measurement covariance R, 3x3
        
        % Generate ukf weights
        n       = 6; % or 7?
        alpha   = 0.5; % small value between 0 and 1
        beta    = 2; % optimal for gaussian noise
        kappa   = 0; % or 3 - n
        [Wm, Wc, C] = ukf_weight(n, alpha, beta, kappa); % C = gamma^2
        
        X_hist(:,1) = X0;
    else
        dt  = t - pt;   % delta t
        pt  = t;
        U   = omg;      % Input
        M   = acc;      % Measurement
        
        % Prediction =======================
        
        % Generate sigma points Xi
        Xs  = ukf_quat_sigma(X, P, Q, C);
        % Transform sigma points Xi to get Yi through process model
        Ys  = ukf_process_ut(Xs, U, dt);
        % Use barycentric mean with renormalization to calculate
        % quaternion mean
        Y   = ukf_process_mean(Ys, Wm);
        % Calculate a priori state vector covariance
        [P, Wy] = ukf_apriori_state_cov(Ys, Y, Wc);
        
        X   = Y;
        
        % Correction =======================
        
        % Transform sigma points Yi to get Zi through measurement model
        Zs  = ukf_measurement_ut(Ys);
        % Use barycentric mean to calculate measuremtn mean
        Z   = sum(bsxfun(@times, Zs, Wm), 2);
        if correction
            % Calculate measurement estimate covariance
            Wz  = bsxfun(@minus, Zs, Z);
            Pzz = Wz * diag(Wc) * Wz';
            % Calculate cross correlation matrix
            Pxz = Wy * diag(Wc) * Wz';
            Pvv = Pzz + R;
            % Calculate Kalman gain
            K   = Pxz * inv(Pvv);
            % Calculate innovation
            V   = M - Z;
            % Update state and covariance
            X   = ukf_kalman_update(Y, V, K);
            P   = P - K * Pvv * K';
        end
        
        % Save state
        X_hist(:,k) = X;
        Z_hist(:,k) = Z;
    end
end

%% Compare results
rot_est = quat2dcm(quatconj(X_hist(1:4,:)'));
eul_est = vicon2rpy(rot_est);
eul_vic = vicon2rpy(rot_vic);
ylabels = {'roll', 'pitch', 'yaw'};
figure()
for i = 1:3
    subplot(3,1,i)
    hold on
    plot(t_vic - min(t_imu(1), t_vic(1)), eul_vic(i,:), 'r', 'LineWidth', 2);
    plot(t_imu - min(t_imu(1), t_vic(1)), eul_est(i,:), 'b', 'LineWidth', 2);
    xlabel(ylabels(i));
    set(gca, 'Box', 'On')
    hold off
    grid on
    axis tight
end

figure()
for i = 1:3
    subplot(3,1,i)
    hold on
    plot(t_imu - min(t_imu(1), t_vic(1)), acc_real(i,:), 'r', 'LineWidth', 2);
    plot(t_imu - min(t_imu(1), t_vic(1)), Z_hist(i,:), 'b', 'LineWidth', 2);
    hold off
    grid on
    axis tight
end

%% Animation
if anim
    figure();
    % Find start and stop indices
    if t_imu(1) > t_vic(1)
        imu_start_i = 1;
    else
        imu_start_i = find(t_imu > t_vic(1), 1 ,'first');
    end
    if t_imu(end) < t_vic(end)
        imu_stop_i = length(t_imu);
    else
        imu_en_i = find(t_imu < t_vic(end), 1, 'last');
    end
    % Start animation
    for i = imu_start_i : imu_stop_i
        vic_i = find(t_imu(i) < t_vic, 1, 'first');
        if isempty(vic_i), vic_i = length(t_vic); end
        if i == imu_start_i
            subplot(1,2,1)
            h_vic = myrotplot(rot_vic(:,:,vic_i));
            title('Vicon')
            subplot(1,2,2)
            h_est = myrotplot(rot_est(:,:,i));
            title('Estimation')
        else
            myrotplot(rot_vic(:,:,vic_i), h_vic);
            myrotplot(rot_est(:,:,i), h_est);
        end
        drawnow
    end
end