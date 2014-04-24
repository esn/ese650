init_script

%%
graphSlam = GraphSlam(1);
graphSlam.genNode(robot, 10);

%% Visualize
h_slam = figure();
graphSlam.pnode.plot('showScan', true);
xlabel('x [m]')
ylabel('y [m]')
beautify(h_slam)
title('Raw Pose Nodes')
axis([-10 75 -35 15])
set(gcf, 'Position', [100 100 800 500])