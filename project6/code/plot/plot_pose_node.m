init_script
SAVE = true;

%% Initialize graphSlam
graphSlam = GraphSlam(1);
graphSlam.genNode(robot, 10);

%% Visualize results
h_node = figure();
graphSlam.pnode.plot()
xlabel('x [m]')
ylabel('y [m]')
beautify(h_node)
title('Raw Pose Nodes')
axis([-10 75 -35 15])
set(gcf, 'Position', [100 100 800 500])

h_scan = figure();
graphSlam.pnode.plot('showScan', true)
xlabel('x [m]')
ylabel('y [m]')
beautify(h_scan)
title('Raw Pose Nodes + Scans')
axis([-10 75 -35 15])
set(gcf, 'Position', [100 100 800 500])

%% Save figure to ./fig
if SAVE, savefig(h_node, 'fig/raw_node'); end
if SAVE, savefig(h_scan, 'fig/raw_scan'); end