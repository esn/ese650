clear all
close all
clc
data_id = 20;
data = load_data(data_id);

car = MagicRobot();
m = 50;
num_enc = length(data.enc.ts);
s_hist = zeros(3, num_enc);

a = [0.1 0.1];

s_particle = zeros(3,m);
figure()
for i = 1:num_enc
    enc = data.enc.counts(:,i);
    car.enc2odom(enc);
    car.motion_model();
    
    s_particle = car.sample_motion_model(s_particle);
    
    hold on
    if mod(i, 40) == 0
        plot(s_particle(1,:), s_particle(2,:), 'r.')
    end
    hold off

    car.plot_car('bo');
    car.plot_traj('m')
    drawnow
end

