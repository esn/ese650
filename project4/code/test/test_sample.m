clear all
close all
clc
data_id = 20;
data = load_data(data_id);

car = MagicRobot();
m = 50;
num_enc = length(data.enc.ts);

a = [0.1 0.1];

mcl = MonteCarlo(50);
figure()
for i = 1:num_enc
    enc = data.enc.counts(:,i);
    car.enc2odom(enc);
    car.motion_model();
    
    mcl.sample_motion_model(car.u, car.a);
    
    mcl.plot_particle('r.')
    car.plot_car('bo');
    car.plot_traj('m')
    drawnow
end

