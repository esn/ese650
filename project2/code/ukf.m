function [ Xest, Zout, Pout ] = ukf( X, U, sensor, cam )
% Initializaiton
persistent P R Q Z H Wm Wc C
if isempty(P)
    disp('Initialize UKF')
%     P   = diag([0.012 0.012 0.012 0.18 0.18 0.12 ...
%                 0.009 0.009 0.009 0.01 0.01 0.14 0.14 0.12]);
%     R   = diag(ones(1,9)*0.01);
%     Q   = diag(ones(1,6)*0.01);
    P = diag([0.1 0.1 0.1 0.1 0.1 0.1 1*pi/180 1*pi/180 1*pi/180 0.01 0.01 0.01 ...
        2*pi/180 2*pi/180].^2);
    R = diag([0.12 0.12 0.12 0.1 0.1 0.1 0.1 0.1 0.1].^2);
    Q = diag([0.02 0.02 0.02 1*pi/180 1*pi/180 1*pi/180].^2);
    num_state = 14;
    num_process_noise = 9;
    H       = ukf_measurement(num_state);
    L       = num_state + num_process_noise;
    alpha   = 0.1;
    beta    = 2;
    kappa   = 0;
    [Wm, Wc, C] = ukf_weight(L, alpha, beta, kappa);
end

if (sensor.isReady) && (~isempty(U)) && (~isempty(X))
    % Process update: prediction
    % Generate sigma points
    [Xs, Rs] = ukf_sigmas(X, P, R, C);
    % Unscented transformation
    [X, ~, P, ~] = ukf_ut(@ukf_process, Xs, U, Rs, sensor.dt, Wm, Wc);
    if ~isempty(sensor.id)
        % Measurement update: correction
        est = dlt(sensor, cam);
        Z = [est.qd_pos; est.qd_rpy];
        % Frank
        K = P * H' * inv(H * P * H' + Q);
        X = X + K * (Z - H * X);
        P = P - K * H * P;
        % Chao
    end
    Xest = X;
else
    Xest = X;
end

Zout = Z;
Pout = P;
end

function [Y, Ys, S, Yd] = ukf_ut(f, Xs, U, Rs, dt, Wm, Wc)
% Unscented transform
[L, n] = size(Xs);
Y = zeros(L, 1);
Ys = zeros(L, n);
for k = 1:n
    Ys(:,k) = f(Xs(:,k), U, Rs(:,k), dt);
    Y = Y + Wm(k) * Ys(:,k);
end
Yd = bsxfun(@minus, Ys, Y);
S = Yd * diag(Wc) * Yd';
end

function [Xs, Rs] = ukf_sigmas(X, P, R, C)
% Generate sigma points
L = 14 + 9;
Xa = [X; zeros(9, 1)];
Pa = zeros(L);
Pa(1:14, 1:14) = P;
Pa(15:end, 15:end) = R;

A = sqrt(C) * sqrtm(Pa);
Y = Xa(:, ones(1, numel(Xa)));
Xas = [Xa Y+A Y-A];

Xs = Xas(1:14, :);
Rs = Xas(15:end, :);
end

function H = ukf_measurement(num_state)
% Measurement model
H = zeros(6, num_state);
H(1,1)  = 1;
H(2,2)  = 1;
H(3,3)  = 1;
H(4,7)  = 1;
H(5,8)  = 1;
H(6,9)  = 1;
H(5,13) = 1;
H(6,14) = 1;
end

function [Wm, Wc, C] = ukf_weight(L, alpha, beta, kappa)
% Generate ukf weights
lambda = alpha^2 * (L + kappa) - L;
C = L + lambda;
Wm = [lambda/C, 0.5/C + zeros(1, 2*L)];
Wc = Wm;
Wc(1) = Wc(1) + (1 - alpha^2 + beta);
end