clear all
close all
clc
data_id = 23;
data = load_data(data_id);

num_enc = length(data.enc.ts);

map = GridMap(30, 0.05, 0.9999);
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
    eul = [0 0 0];
    lidar.store_range(range);
    lidar.transform_range(car.s, [eul(1) eul(2) car.s(3)]);
    lidar.prune_range();
    
    % Update map
    map.update_map(car.s, lidar.p_range, lidar.dz, 0);
    
    % Visualization
    map.plot_map();
    map.plot_car('bo');
    map.plot_traj('m');
    map.plot_lidar_orig(lidar.p_range, 'g.');
    drawnow
end
