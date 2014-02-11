clear all; close all; clc;
load ../imu/imuRaw1

%% calculate scale factor for accelerometer
acc_raw = vals(1:3,:);
omg_raw = vals([5 6 4],:);

acc_rest = mean(acc_raw(:,1:100), 2);
omg_rest = mean(omg_raw(:,1:100), 2);

g_raw = sqrt(sum((acc_rest - 1023/2).^2));

acc_scale = 1/g_raw;
acc_bias = 1023/2;
acc_scale = acc_scale * [-1; -1; 1];
acc = bsxfun(@times, acc_bias - acc_raw, acc_scale);

omg_scale = 0.0171;
omg_bias = omg_rest;
omg = bsxfun(@minus, omg_raw, omg_bias) * omg_scale;

figure()
for i = 1:3
    subplot(3,1,i)
    plot(ts - ts(1), acc(i,:))
    xlabel('t'); ylabel('m/s^2');
end

figure()
for i = 1:3
    subplot(3,1,i)
    plot(ts - ts(1), omg(i,:))
    xlabel('t'); ylabel('m/s^2');
end