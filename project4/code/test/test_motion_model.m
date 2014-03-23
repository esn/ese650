clear all; close all; clc;
addpath(genpath('.'))
% Load data
data_id = 23;
data = load_data(data_id);

s = zeros(3,1);

num_enc = length(data.enc.ts);
car = MagicRobot();

for i = 1:num_enc
    enc = data.enc.counts(:,i);
    car.enc2odom(enc);
    car.motion_model();
    car.append_hist();
    car.plot_car('bo');
    car.plot_traj('g');
end

% plot_cart([], s_hist, 20);
car.truncate_hist();
car.plot_traj();

axis equal
figure()
plot(data.enc.ts, car.s_hist(3,:), 'b')
hold on
load(sprintf('eul%d.mat', data_id));
plot(data.imu.ts, eul_est(3,:), 'r')