init_script
SAVE = false;

%% Initialize graphSlam
gslam = GraphSlam(1);
gslam.genNode(robot(2), 5, 40);

%%
gslam.pnode.plot()