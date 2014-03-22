clear all; close all; clc;
addpath(genpath('.'))
% Load data
data_id = 23;
data = load_data(data_id);

s = zeros(3,1);

num_enc = length(data.enc.ts);
s_hist = zeros(3, num_enc);

for i = 1:num_enc
    enc = data.enc.counts(:,i);
    u = enc2odom(enc);
    s = motion_model(s, u);
    s_hist(:,i) = s;
end

% plot_cart([], s_hist, 20);
plot(s_hist(1,:), s_hist(2,:), '-')

axis equal
figure()
plot(data.enc.ts, s_hist(3,:), 'b')
hold on
load(sprintf('eul%d.mat', data_id));
plot(data.imu.ts, eul_est(3,:), 'r')