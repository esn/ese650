function [Xout, Zout] = ukf(M, U, t, correction)
%UKF unscented kalman filter for orientation estimation
%   M - acc
%   U - omg
if nargin < 4, correction = true; end
persistent X Z P Q R pt Wm Wc C
if isempty(P)
    X = [[1;0;0;0]; [0;0;0]];
    P = diag([ones(3,1)*0.0001; ones(3,1)*0.0001]);
    Q = diag([ones(3,1)*0.0001; ones(3,1)*0.0001]);
    R = diag([0.0265, 0.0144 0.0046]*50);
    n = 6;
    a = 2; % alpha
    b = 2; % beta
    k = 0; % kappa
    [Wm, Wc, C] = ukf_weight(n, a, b, k);
    pt = t;
end
dt = t - pt;
pt = t;
% Prediction
% Generate sigma points Xi
Xs = ukf_quat_sigma(X, P, Q, C);
% Transform sigma points Xi to get Yi through process model
Ys = ukf_process_ut(Xs, U, dt);
% Use barycentric mean with renormalization to calculate
% quaternion mean
Y = ukf_process_mean(Ys, Wm);
% Calculate a priori state vector covariance
[P, Wy] = ukf_apriori_state_cov(Ys, Y, Wc);
X = Y;

% Transform sigma points Yi to get Zi through measurement model
Zs = ukf_measurement_ut(Ys);
% Use barycentric mean to calculate measuremtn mean
Z = sum(bsxfun(@times, Zs, Wm), 2);
if correction
    % Calculate measurement estimate covariance
    Wz  = bsxfun(@minus, Zs, Z);
    Pzz = Wz * diag(Wc) * Wz';
    % Calculate cross correlation matrix
    Pxz = Wy * diag(Wc) * Wz';
    Pvv = Pzz + R;
    % Calculate Kalman gain
    K   = Pxz / Pvv;
    % Calculate innovation
    V   = M - Z;
    % Update state and covariance
    X   = ukf_kalman_update(Y, V, K);
    P   = P - K * Pvv * K';
end
Xout = X;
Zout = Z;
end