init_script

%%
gslam = GraphSlam(1);
gslam.genNode(robot(1), Inf, pi/2);

%% Visualize
h_slam = figure();
hold on;
gslam.pnode.plot('showScan', true);
xlabel('x [m]')
ylabel('y [m]')
beautify(h_slam)
title('Raw Pose Nodes')
axis([-10 75 -35 15])
set(gcf, 'Position', [100 100 800 500])