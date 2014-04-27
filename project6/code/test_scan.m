init_script
l = 2;
%%
gslam = GraphSlam(1);
gslam.genNode(robot(2), 5, 3);

figure()
gslam.pnode.plot();
beautify(gcf)
%%
p1 = gslam.pnode(1);
p2 = gslam.pnode(2);
dyaw = p2.yaw - p1.yaw;
% First rotate pose difference into p1's frame
R = [cos(p1.yaw) -sin(p1.yaw); sin(p1.yaw) cos(p1.yaw)];
dpose = R'*[p2.x - p1.x; p2.y - p1.y];
dpose(3) = dyaw;
% Than rotate p2's scan into p1's frame
R2to1 = [cos(dyaw) -sin(dyaw); sin(dyaw) cos(dyaw)];
xy_scan = bsxfun(@plus, R2to1*p2.lscan, dpose(1:2));
% In p1 frame
figure()
hold on
plot(p1.lscan(1,:), p1.lscan(2,:), 'b.', 'Markersize', 5)
plot(p2.lscan(1,:), p2.lscan(2,:), 'g.', 'Markersize', 5)
plot(0, 0, 'bo')
plot([0 l], [0 0], 'b')

plot(xy_scan(1,:), xy_scan(2,:), 'r.', 'Markersize', 5)
plot(dpose(1), dpose(2), 'ro')
plot(dpose(1) + [0 l*cos(dpose(3))], ...
    dpose(2) + [0 l*sin(dpose(3))], 'r')

beautify(gcf)

% In global frame
figure()
hold on
plot(p1.gscan(1,:), p1.gscan(2,:), 'b.', 'Markersize', 5)
plot(p1.pose(1), p1.pose(2), 'bo')
plot(p1.pose(1) + [0 l*cos(p1.pose(3))], ...
    p1.pose(2) + [0 l*sin(p1.pose(3))], 'b')
plot(p2.gscan(1,:), p2.gscan(2,:), 'r.', 'Markersize', 5)
plot(p2.pose(1), p2.pose(2), 'ro')
plot(p2.pose(1) + [0 l*cos(p2.pose(3))], ...
    p2.pose(2) + [0 l*sin(p2.pose(3))], 'r')
beautify(gcf)

%% Test libicp
s1 = p1.lscan;
s2 = p2.lscan;
T_guess = [R2to1 dpose(1:2); 0 0 1];
figure()
hold on
plot(s1(1,:), s1(2,:), 'b.', 'MarkerSize', 5);
plot(s2(1,:), s2(2,:), 'g.', 'MarkerSize', 5);
beautify(gcf)
T_fit = icpMex(s1, s2, T_guess, 1, 'point_to_point');
% Use Tr_fit to plot
s2_fit = bsxfun(@plus, T_fit(1:2,1:2)*p2.lscan, T_fit(1:2,3));
plot(s2_fit(1,:), s2_fit(2,:), 'r.', 'MarkerSize', 5)