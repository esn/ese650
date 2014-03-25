close all
clear all
data_id = 23;
data = load_data(data_id);

car = MagicRobot();
map = GridMap(40, 0.1, 0.999);
mcl = MonteCarlo(49);
ldr = Hokuyo(data.ldr.angles);
map.plot_map();
% Get first map
for i = 1:3000
    enc = data.enc.counts(:,i);
    range = data.ldr.ranges(:,i);
    car.enc2odom(enc);
    mcl.sample_motion_model(car.u, car.a)
    
    ldr.store_range(range);
    ldr.transform_range(car.s, [0 0 car.s(3)]);
    ldr.prune_range();
    
    map.plot_lidar_orig(ldr.p_range, 'b.');
    map.plot_particle(mcl.p, 'ro');
    
    mcl.measurement_model(map.map, map.xy_bound, map.res, ldr, [0 0 0]);
    car.s = mcl.best_p;
    mcl.resample();
    
    car.s = mcl.best_p;
    ldr.transform_range(car.s, [0 0 car.s(3)]);
    ldr.prune_range();
    map.update_map(car.s, ldr.p_range, ldr.dz, 0);
    
    map.plot_map()
    map.plot_car('bo')
    map.plot_traj('m')
    map.plot_lidar_corr(ldr.p_range, 'g.')
    drawnow
end
% drawnow
