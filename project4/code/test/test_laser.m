data_id = 20;
data = load_data(data_id);
s = [2; 5; pi/4];
plot_cart([],s);

i = 1;
range = data.ldr.ranges(:,i);
angle = data.ldr.angles;
x_range_in_body = range.*cos(angle);
y_range_in_body = range.*sin(angle);
xy_range_in_world = [cos(s(3)) -sin(s(3)); sin(s(3)) cos(s(3))] * [x_range_in_body'; y_range_in_body'];
x_range_in_world = xy_range_in_world(1,:) + s(1);
y_range_in_world = xy_range_in_world(2,:) + s(2);
hold on
plot(x_range_in_world, y_range_in_world, '.-')