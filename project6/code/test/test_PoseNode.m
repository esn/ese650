init_script
SAVE = false;

%% Initialize graphSlam
gslam = GraphSlam(1);
gslam.genNode(robot(2), 5, 5);

%%
gslam.pnode(20).plot('ShowScan', true)