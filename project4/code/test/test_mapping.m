clear all
close all
clc
data_id = 22;
data = load_data(data_id);

num_enc = length(data.enc.ts);

map = GridMap(40, 0.1, 0.9999);
car = MagicRobot();
lidar = Hokuyo(data.ldr.angles);

map.plot_map();

for i = 1:num_enc
    enc = data.enc.counts(:,i);
    range = data.ldr.ranges(:,i);
    angle = data.ldr.angles;
    
    % Motion
    car.enc2odom(enc);
    car.motion_model();
    
    % Lidar
    wRb = rpy2wrb_xyz([0 0 car.s(3)]);
    lidar.transform_range(car.s, wRb, range);
    lidar.prune_range();
    
    % Update map
    map.update_map(car.s, lidar.p_range, lidar.dz, 0);
    
    % Visualization
    map.plot_map();
    map.plot_car('bo');
    map.plot_traj('m');
    map.plot_lidar(lidar.p_range, 'g.');
    drawnow
end
