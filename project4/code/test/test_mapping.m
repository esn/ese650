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
map.plot;
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
    p_range_world = transform_range(s, wRb, bTs, range, angle);
    map.update_map(s, p_range_world(1:2,:));
    map.plot;
    s_hist(:,i) = s;
    if i == 1
        hold on
        h_cart = plot((s(1)+xy_bound(2))./res, (s(2)+xy_bound(1))./res, 'r');
        hold off
    else
        set(h_cart, 'XData', (s_hist(1,1:i)+xy_bound(2))./res, 'YData', (s_hist(2,1:i)+xy_bound(4))./res);
    end
    drawnow
end
