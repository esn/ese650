clear all; close all; clc
%% Test integration
data_id = 4;

load(sprintf('../imu/imuRaw%d.mat', data_id));
imu_t = ts;
acc_raw = vals(1:3,:);
omg_raw = vals([5 6 4], :);
imu_raw = [acc_raw; omg_raw];
load(sprintf('../vicon/viconRot%d.mat', data_id));
vic_t = ts;
vic_rot = rots;
eul_vic = vicon2rpy(vic_rot);

omg_real = raw2real(omg_raw, 'omg');

q = [1; 0; 0; 0];
q_hist = zeros(4, length(imu_t));
q_hist(:,1) = q;
for i = 2:length(imu_t)
    dt = imu_t(i) - imu_t(i-1);
    omg = omg_real(:,i);
    alpha_d = norm(omg,2) * dt;
    e_d = omg/norm(omg,2);
    q_d = [cos(alpha_d/2); e_d * sin(alpha_d/2)];
    q = quatmultiply(q', q_d')';

%     q_dot = 1/2*quatmultiply(q', [0;omg]')';
%     q = q + q_dot * dt;
%     q = q/quatnorm(q');

    q_hist(:,i) = q;
end

% [eul_est(3,:), eul_est(2,:), eul_est(1,:)] = quat2angle(quatconj(q_hist'), 'zyx');
eul_est = vicon2rpy(quat2dcm(quatconj(q_hist')));
% for i = 1:length(q_hist)
%     rot = quat2matrix(q_hist(:,i));
%     
%     eul_est(:,i) = wrb2rpy_zyx(rot);
% end
figure()
for i = 1:3
    subplot(3,1,i)
    plot(imu_t - min(imu_t(1), vic_t(1)), eul_est(i,:), 'b', 'LineWidth', 2);
    hold on
    plot(vic_t - min(imu_t(1), vic_t(1)), eul_vic(i,:), 'r', 'LineWidth', 2);
    hold off
    grid on
    axis tight
end
figure()
for i = 1:4
    subplot(4,1,i)
    plot(q_hist(i,:))
end