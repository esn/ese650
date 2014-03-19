clear all; close all; clc;
addpath(genpath('.'))
% Load data
data_id = 22;
data = load_data(data_id);

s = zeros(3,1);
wheel_radius = 254/200*3.36;
axle_width = (311.15 + 476.25)/200;
num_enc = length(data.enc.ts);
s_hist = zeros(3, num_enc);

for i = 1:num_enc
    enc = data.enc.counts(:,i);
    dR = (enc(1) + enc(3))/2/360*wheel_radius;
    dL = (enc(2) + enc(4))/2/360*wheel_radius;
    alpha = (dR - dL) / axle_width;
    R = (dR + dL)/2;
    s(3) = s(3) + alpha;
    s(1) = s(1) + R*cos(s(3));
    s(2) = s(2) + R*sin(s(3));
    s_hist(:,i) = s;
end
plot(s_hist(1,:), s_hist(2,:), 'o')
figure()
plot(data.enc.ts, s_hist(3,:))
hold all
load eul22.mat
plot(data.imu.ts, eul_est(3,:))