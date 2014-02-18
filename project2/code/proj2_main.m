% clear all; close all; clc
addpath(genpath('./'))
addpath(genpath('../'))

%% Select dataset
data_id     = 10;
correction  = true;
anim        = true;
stitch      = true;
% Load corresponding dataset
% load(sprintf('../imu/imuRaw%d.mat', data_id));
load(sprintf('../Project2_Test/imu/imuRaw%d.mat', data_id));
t_imu   = ts;
acc_raw = vals(1:3,:);
omg_raw = vals([5 6 4], :);
imu_raw = [acc_raw; omg_raw];
% load(sprintf('../vicon/viconRot%d.mat', data_id));
try
    load(sprintf('../Project2_Test/vicon/viconRot%d.mat', data_id));
    t_vic       = ts;
    rot_vic     = rots;
    use_vicon   = true;
catch
    use_vicon   = false;
end

try
    load(sprintf('../Project2_Test/cam/cam%d.mat', data_id));
    t_cam   = ts;
    use_cam = true;
catch
    use_cam = false;
end

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
if use_vicon
    eul_vic = vicon2rpy(rot_vic);
end
ylabels = {'roll', 'pitch', 'yaw'};
figure()
for i = 1:3
    subplot(3,1,i)
    hold on
    if use_vicon
        plot(t_vic - min(t_imu(1), t_vic(1)), eul_vic(i,:), 'r', 'LineWidth', 2);
        plot(t_imu - min(t_imu(1), t_vic(1)), eul_est(i,:), 'b', 'LineWidth', 2);
    else
        plot(t_imu, eul_est(i,:), 'b', 'LineWidth', 2);
    end
    
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
    if use_vicon
        plot(t_imu - min(t_imu(1), t_vic(1)), acc_real(i,:), 'r', 'LineWidth', 2);
        plot(t_imu - min(t_imu(1), t_vic(1)), Z_hist(i,:), 'b', 'LineWidth', 2);
    else
        plot(t_imu, Z_hist(i,:), 'b', 'LineWidth', 2);
    end
    hold off
    grid on
    axis tight
end

%% Animation
if anim
    figure();
    % Find start and stop indices
    if use_vicon
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
        
    else
        imu_start_i = 1;
        imu_stop_i = length(t_imu);
    end
    % Start animation
    for i = imu_start_i : imu_stop_i
        if use_vicon
            vic_i = find(t_imu(i) < t_vic, 1, 'first');
            if isempty(vic_i), vic_i = length(t_vic); end
        end
        if i == imu_start_i
            if use_vicon
                subplot(1,2,1)
                h_vic = myrotplot(rot_vic(:,:,vic_i));
                title('Vicon')
                subplot(1,2,2)
                h_est = myrotplot(rot_est(:,:,i));
                title('Estimation')
            else
                h_est = myrotplot(rot_est(:,:,i));
                title('Estimation')
            end
        else
            if use_vicon
                myrotplot(rot_vic(:,:,vic_i), h_vic);
                myrotplot(rot_est(:,:,i), h_est);
            else
                myrotplot(rot_est(:,:,i), h_est);
            end
        end
        drawnow
    end
end

%% Stitching
figure()
f = 283;
[nr, nc, ~, ~] = size(cam);
nr_canvas = 1000;
nc_canvas = ceil(2*pi*f)+2;
x_c_hat = nc_canvas/2;
y_c_hat = nr_canvas/2;
canvas = zeros(nr_canvas, nc_canvas, 3, 'uint8');

for i = 150:3:length(cam) - 100
    img = cam(:,:,:,i);
    if use_vicon
        vic_i = find(t_vic > t_cam(i), 1, 'first');
        wrb = rot_vic(:,:,vic_i);
    else
        imu_i = find(t_imu > t_cam(i), 1, 'first');
        wrb = rot_est(:,:,imu_i);
    end
    [x_img, y_img] = meshgrid(1:nc, 1:nr);
    x_img = x_img(:); y_img = y_img(:); z_img = ones(size(y_img)) * f;
    P_b = bsxfun(@plus, [z_img'; -x_img'; -y_img'], [0; nc/2; nr/2]);
    P_w = wrb * P_b;
    theta = atan2(P_w(2,:), P_w(1,:));
    h       = bsxfun(@rdivide, P_w(3,:), sqrt(P_w(1,:).^2 + P_w(2,:).^2));
    x_hat   = round(-f * theta + x_c_hat);
    y_hat   = round(-f * h + y_c_hat);
    
    for k = 1:length(x_hat)
        if y_hat(k) < nr_canvas - 1 && y_hat(k) > 1
            canvas(y_hat(k), x_hat(k), :) = img(y_img(k), x_img(k), :);
        end
    end
    imshow(canvas)
    drawnow
end