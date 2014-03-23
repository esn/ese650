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
map.plot_map;
lidar = Hokuyo(data.ldr.angles);
% map.
for i = 1:num_enc
    enc = data.enc.counts(:,i);
    u = enc2odom(enc);
    s = motion_model(s, u);
    range = data.ldr.ranges(:,i);
    angle = data.ldr.angles;
    bTs = [0 0 0];
    rpy = [0 0 s(3)];
    wRb = rpy2wrb_xyz(rpy);
    p_range_world = lidar.transform_range(s, wRb, range);
    map.update_map(s, p_range_world);
    map.plot_map;
    map.plot_car('bo');
    map.plot_traj('g');
    drawnow
end
