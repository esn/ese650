init_script
SAVE = true;

%% Generate Pose Node for each robot
min_pose_dist = 10;

pnode = PoseNode.empty;

num_robot = numel(robot);
for i_robot = 1:num_robot
    num_packet = numel(robot{i_robot}.packet);
    
    for i_packet = 1:num_packet
        curr_packet = robot{i_robot}.packet{i_packet};
        
        if i_packet == 1
            % Add 1st pose of each robot
            pnode(end+1) = PoseNode(curr_packet);
            travel_dist = 0;
        else
            % Add pose if traveled distance is bigger than pose_dist
            d = sqrt((curr_packet.pose.x - prev_packet.pose.x)^2 + ...
                (curr_packet.pose.y - prev_packet.pose.y)^2);
            travel_dist = travel_dist + d;
            
            if travel_dist > min_pose_dist
                pnode(end+1) = PoseNode(curr_packet);
                % reset travel dist
                travel_dist = 0;
            end
        end
        
        prev_packet = curr_packet;
    end
end

%% Visualize results
h_node = figure();
pnode.plot()
xlabel('x [m]')
ylabel('y [m]')

h_scan = figure();
pnode.plot('showScan', true)
xlabel('x [m]')
ylabel('y [m]')

%% Save figure to ./fig
beautify(h_node)
title('Raw Pose Nodes')
axis([-5 70 -30 15])
set(gcf, 'Position', [100 100 800 500])
if SAVE, savefig(h_node, 'fig/raw_node'); end


beautify(h_scan)
title('Raw Pose Nodes + Scans')
axis([-10 75 -35 15])
set(gcf, 'Position', [100 100 800 500])
if SAVE, savefig(h_scan, 'fig/raw_scan'); end