clear all; close all; clc;
addpath(genpath('.'))
% Load data
data_id = 21;
data = load_data(data_id);

s = zeros(3,1);
wheel_radius = 254/2000;
axle_width = (311.15 + 476.25)/2000;
num_enc = length(data.enc.ts);
s_hist = zeros(3, num_enc);

for i = 1:num_enc
    enc = data.enc.counts(:,i);
    dR = (enc(1) + enc(3))/2/360*2*pi*wheel_radius;
    dL = (enc(2) + enc(4))/2/360*2*pi*wheel_radius;
    alpha = (dR - dL) / axle_width;
    if alpha == 0, alpha = 1; end
    R = (dR + dL)/2/alpha;
    s(3) = s(3) + alpha;
    s(1) = s(1) + R*cos(s(3));
    s(2) = s(2) + R*sin(s(3));
    s_hist(:,i) = s;
end

plot_cart(s_hist, 1);
axis equal
figure()
plot(data.enc.ts, s_hist(3,:))
hold all
load(sprintf('eul%d.mat', data_id));
plot(data.imu.ts, eul_est(3,:))