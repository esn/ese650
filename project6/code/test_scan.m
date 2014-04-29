init_script
l = 1;
%%
gslam = GraphSlam(1);
gslam.genNode(robot(2), 4, 40);
gslam.pnode.plot();
if 1
%     for i = 31:gslam.n_node-1
        figure(2)
        clf
        hold on
        % gslam.pnode.plot();
        beautify(gcf)
        n = i;
        [rt, ~, score] = ...
            scan_match(gslam.pnode(7), gslam.pnode(9), 0.2, true);
%         scores(i) = score;
        pause
%     end
else
%%
p1 = gslam.pnode(5);
p2 = gslam.pnode(6);
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
T_fit = icpMex(s1, s2, T_guess, 1, 'point_to_plane');
% Use Tr_fit to plot
s2_fit = bsxfun(@plus, T_fit(1:2,1:2)*p2.lscan, T_fit(1:2,3));
plot(s2_fit(1,:), s2_fit(2,:), 'r.', 'MarkerSize', 5)

%% Calculate map correlation
res = 0.2;
xmin = min([s1(1,:), s2_fit(1,:)]);
xmax = max([s1(1,:), s2_fit(1,:)]);
ymin = min([s1(2,:), s2_fit(2,:)]);
ymax = max([s1(2,:), s2_fit(2,:)]);
sizex = ceil((xmax - xmin) / res + 1);
sizey = ceil((ymax - ymin) / res + 1);
map = zeros(sizex, sizey, 'int8');
% Convert from meters  to cells
xis = round((s1(1,:) - xmin) ./ res);
yis = round((s1(2,:) - ymin) ./ res);
indGood = (xis > 1) & (yis > 1) & (xis < sizex) & (yis < sizey);
inds = sub2ind(size(map), xis(indGood), yis(indGood));
map(inds) = 1;
x_im = xmin:res:xmax;
y_im = ymin:res:ymax;
x_range = [-1:1]*res;
y_range = [-1:1]*res;
c = map_correlation(map, x_im, y_im, [s2_fit; zeros(1, length(s2_fit))], ...
    x_range, y_range);
c = max(c(:));
disp(c)

end