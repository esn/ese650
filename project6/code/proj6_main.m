init_script

%% Initialization
gslam = GraphSlam();
gslam.genNode(robot, 7, 30);
gslam.closeLoop();

%% Visualize
h_slam = figure();
hold on;
gslam.pnode.plot('ShowScan', true);
gslam.plot();
xlabel('x [m]')
ylabel('y [m]')
beautify(h_slam)
title('Raw Pose Nodes')
axis([-10 75 -35 15])
set(gcf, 'Position', [100 100 800 500])

%% Optimize
gslam.optimize(10); % Do some number of iterations

%% Visualize
h_slam = figure();
hold on;
gslam.pnode.plot('ShowScan', true);
gslam.plot();
xlabel('x [m]')
ylabel('y [m]')
beautify(h_slam)
title('Raw Pose Nodes')
axis([-10 75 -35 15])
set(gcf, 'Position', [100 100 800 500])