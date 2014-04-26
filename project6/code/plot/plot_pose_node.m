init_script
SAVE = false;

%% Initialize graphSlam
gslam = GraphSlam(1);
gslam.genNode(robot);

%% Visualize results
h_node = figure();
hold on
gslam.pnode.plot();
hold off
xlabel('x [m]')
ylabel('y [m]')
beautify(h_node)
title('Raw Pose Nodes')
axis([-10 75 -35 15])
set(gcf, 'Position', [100 100 800 500])

h_scan = figure();
hold on
gslam.pnode.plot('showScan', true)
hold off
xlabel('x [m]')
ylabel('y [m]')
beautify(h_scan)
title('Raw Pose Nodes + Scans')
axis([-10 75 -35 15])
set(gcf, 'Position', [100 100 800 500])

%% Save figure to ./fig
if SAVE, savefig(h_node, 'fig/raw_node'); end
if SAVE, savefig(h_scan, 'fig/raw_scan'); end