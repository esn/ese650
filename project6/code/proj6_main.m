init_script

%% Initialization
gslam = GraphSlam(5);  % 5 iteration
gslam.genNode(robot(2), 5, 30);

%% Visualize
h_slam = figure();
hold on;
gslam.pnode.plot();
xlabel('x [m]')
ylabel('y [m]')
beautify(h_slam)
title('Raw Pose Nodes')
axis([-10 75 -35 15])
set(gcf, 'Position', [100 100 800 500])

%% Optimize
gslam.optimize();