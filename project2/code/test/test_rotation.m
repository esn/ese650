clear all; close all; clc;
%% simple test
euler = [0; pi/2; 0];
R =rpy2wrb_zyx(euler);
euler_out = wrb2rpy_zyx(R);
disp([euler euler_out])

%% show seperate plot of euler angles
load ../vicon/viconRot8
figure()
eulers = vicon2rpy(rots);
for i = 1:3
    subplot(3,1,i)
    plot(ts - ts(1), eulers(i,:));
    xlabel('t'); ylabel('rad');
end