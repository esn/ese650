clear all
close all
clc
data_id = 22;
data = load_data(data_id);

num_enc = length(data.enc.ts);
s_hist = zeros(3, num_enc);
s = zeros(3,1);
xy_bound = [-40 40 -40 40];
res = 0.1;
z_bound = 10;
map = GridMap(xy_bound, res, z_bound);
map.plot_map();
car = MagicRobot();
lidar = Hokuyo(data.ldr.angles);
% map.
for i = 1:num_enc
    enc = data.enc.counts(:,i);
    range = data.ldr.ranges(:,i);
    angle = data.ldr.angles;
    
    car.enc2odom(enc);
    car.motion_model();
    car.append_hist();
    
    wRb = rpy2wrb_xyz([0 0 car.s(3)]);
    lidar.transform_range(car.s, wRb, range);
    map.update_map(car.s, lidar.p_range);
    map.plot_map();
    map.plot_car('bo');
    map.plot_traj('m');
    map.plot_lidar(lidar.p_range, 'g.');
end
