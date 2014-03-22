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
figure()
h_cart = plot_cart([], car.s);
s_particle = zeros(3,m);
for i = 1:num_enc
    enc = data.enc.counts(:,i);
    car.enc2odom(enc);
    car.motion_model();
    
    for j = 1:m
        s_particle(:,j) = car.sample_motion_model(s_particle(:,j));
    end
    
    if mod(i, 40) == 0
        hold on
        plot(s_particle(1,:), s_particle(2,:), 'r.')
        hold off
    end
    if mod(i, 20) == 0
        h_cart = plot_cart(h_cart, s_hist(:,1:i), 20);
    end
    s_hist(:,i) = car.s;
    drawnow
end

