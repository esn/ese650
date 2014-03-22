clear all
close all
data_id = 22;
data = load_data(data_id);
yaw = 0.8436;
% yaw = 0;
s = [0; 0; yaw];
plot_cart([],s);
% 
i = 1037;
% i = 1;
rpy = [-0.1273 0.2486 yaw];
% rpy = [0 0 yaw];
wRb = rpy2wrb_xyz(rpy);
% range = 1;
% angle = 0;
range = data.ldr.ranges(:,i);
angle = data.ldr.angles;

% bTs = [133.23 0 514.35]/1000;
lidar = Hokuyo(data.ldr.angles);

% bTs = [0 0 0];
p_range_world = lidar.transform_range(s, wRb, range);
hold on
plot3(p_range_world(1,:), p_range_world(2,:), p_range_world(3,:), '.-')
grid on

view(3)
axis equal