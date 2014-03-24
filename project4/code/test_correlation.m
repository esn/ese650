data_id = 20;
data = load_data(data_id);

car = MagicRobot();
map = GridMap(30, 0.1, 0.9999);
mcl = MonteCarlo(10);
ldr = Hokuyo(data.ldr.angles);


enc = data.enc.counts(:,1);
car.enc2odom(enc);
car.motion_model();
mcl.sample_motion_model(car.u, car.a);

range = data.ldr.ranges(:,1);
ldr.store_range(range);
ldr.transform_range(car.s, eye(3));
ldr.prune_range();
map.update_map(car.s, ldr.p_range, ldr.dz, t);

map.plot_map()
map.plot_lidar(ldr.p_range, 'g.')
drawnow
% Measurement model
mcl.measurement_model(map.map, map.xy_bound, map.res, ldr, eul_est);