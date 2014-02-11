clear all; close all; clc;

%%
load ../imu/imuRaw9
acc_raw = vals(1:3,:);
omg_raw = vals([5 6 4],:);

figure();
for i = 1:3
    subplot(3,1,i)
    plot(ts - ts(1), acc_raw(i,:));
    xlabel('t'); ylabel('m/s^2');
end
figure();
for i = 1:3
    subplot(3,1,i)
    plot(ts - ts(1), omg_raw(i,:));
    xlabel('t'); ylabel('m/s^2');
end