init_script
SAVE = true;

%% Initialize gslam
gslam = GraphSlam(1);
gslam.genNode(robot, 0.05);

%% Visualize results
figure();
h1 = subplot(1,2,1);
hold on
axis equal
h2 = subplot(1,2,2);

for i_node = 1:gslam.num_nodes
    
    curr_node = gslam.pnode(i_node);
    curr_node.plot(h1, 'showScan', true);
    axis equal
    plot(h2, curr_node.lscan(1,:), curr_node.lscan(2,:), ...
        '.', ...
        'Color', curr_node.color)
    axis equal
    pause
    drawnow
end