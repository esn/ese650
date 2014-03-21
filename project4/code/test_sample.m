clear all
close all
clc
data_id = 21;
data = load_data(data_id);

s = zeros(3,1);
m = 50;
num_enc = length(data.enc.ts);
s_hist = zeros(3, num_enc);

a = [0.1 0.1];
figure()
h_cart = plot_cart([], s);
s_particle = zeros(3,m);
for i = 1:num_enc
    enc = data.enc.counts(:,i);
    u = enc2odom(enc);
    s1 = motion_model(s, u);
    
    for j = 1:m
        s_particle(:,j) = motion_model(s_particle(:,j), u, a);
    end
    
    if mod(i, 40) == 0
        hold on
        plot(s_particle(1,:), s_particle(2,:), 'r.')
        hold off
    end
    if mod(i, 20) == 0
        h_cart = plot_cart(h_cart, s_hist(:,1:i), 20);
    end
    s_hist(:,i) = s1;
    s = s1;
    drawnow
end

% h_cart = plot_cart([], s);
% enc = data.enc.counts(:,1000);
% u = enc2odom(enc);
% s1 = motion_model(s, u);
% for j = 1:m
%     s_particle(:,j) = motion_model(s, u, [0.1 10]);
% end
% plot_cart([], s_particle);
% plot_cart([], s1)
