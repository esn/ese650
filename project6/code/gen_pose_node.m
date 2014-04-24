init_script

%% Generate Pose Node for each robot
pose_dist = 7;

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
            
            if travel_dist > pose_dist
                pnode(end+1) = PoseNode(curr_packet);
                % reset travel dist
                travel_dist = 0;
            end
        end
        prev_packet = curr_packet;
    end
end

%% Visualize result
pnode.plot
xlabel('x [m]')
ylabel('y [m]')
beautify(gcf)