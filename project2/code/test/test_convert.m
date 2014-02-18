clear all; close all; clc;
load ../imu/imuRaw3
t_imu   = ts;
load ../vicon/viconRot3
t_vic   = ts;

%% calculate scale factor for accelerometer
acc_raw = vals(1:3,:);
omg_raw = vals([5 6 4],:);

acc_rest = mean(acc_raw(:,1:100), 2);
omg_rest = mean(omg_raw(:,1:100), 2);

g_raw = sqrt(sum((acc_rest - 1023/2).^2));

acc_scale = 1/g_raw;
acc_bias = 1023/2;
acc_scale = acc_scale * [-1; -1; 1];
acc = bsxfun(@times, acc_raw - acc_bias, acc_scale);

omg_scale = 0.0171;
omg_bias = omg_rest;
omg = bsxfun(@minus, omg_raw, omg_bias) * omg_scale;


acc_rot = zeros(3, length(t_imu));
for i = 1:length(ts)
    acc_rot(:,i) = rots(:,:,i)' * [0;0;1];
end

figure()
for i = 1:3
    subplot(3,1,i)
    plot(acc(i,:))
    plot(acc_rot(i,:))
    xlabel('t'); ylabel('m/s^2');
end

figure()
for i = 1:3
    subplot(3,1,i)
    plot(omg(i,:))
    xlabel('t'); ylabel('m/s^2');
end

%% Calcualte variance for gyro and accelerometer
omg_sample = omg(:,1:500);
acc_sample = acc(:,1:500);
for i = 1:3
    omg_var(i) = var(omg_sample(i,:));
    acc_var(i) = var(acc_sample(i,:));
end

%% 

figure()
for i = 1:3
    subplot(3,1,i);
    
    xlabel('t'); ylabel('m/s^2');
end