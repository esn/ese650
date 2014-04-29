%%%
%> @file GraphSlam.m
%> @brief A class for doing pose graph optimization
%%%
classdef GraphSlam < handle
    
    properties
        pnode  %> Pose nodes added to graph
        iter   %> Number of iterations to run optimization
        Omega  %> Information matrix
        xi     %> Information vector
    end
    
    properties (Dependent = true)
        n_node  %> Number of pose nodes in graph
    end
    
    methods
        %%%
        %> @brief Class constructor
        %> Instantiates an object of GraphSlam
        %>
        %> @param iter number of iterations to run optimitzation
        %> @return instance of the GraphSlam class
        %%%
        function obj = GraphSlam(iter)
            obj.iter  = iter;
        end
        
        %%%
        %> @brief generates nodes from log data
        %> @param robot variable from log.mat
        %> @param min_distance minimum distance travelled to be added to graph
        %> @param n_combine number of packet to combine around current one
        %%%
        function genNode(obj, robot, min_distance, n_combine)
            if nargin < 4, n_combine = 25; end
            if nargin < 3, min_distance = 2.5; end
            % Initialize an empty PoseNode
            obj.pnode = PoseNode.empty;
            n_robot = numel(robot);
            start_packet = n_combine + 1;
            for i_robot = 1:n_robot
                c_robot = robot{i_robot};
                n_packet = numel(c_robot.packet);
                for i_packet = start_packet:(n_packet - start_packet)
                    % Extract current packet and it's information
                    c_packet = c_robot.packet{i_packet};
                    id = c_packet.id;
                    pose = [...
                        c_packet.pose.x;
                        c_packet.pose.y;
                        c_packet.pose.yaw;...
                        ];
                    t = c_packet.pose.gps.t;
                    
                    if i_packet == start_packet
                        % Extract scan from the first packet
                        gscan = extract_scan({c_packet});
                        % Add 1st pose of each robot to node list
                        obj.pnode(end+1) = PoseNode(id, pose, t, gscan);
                        % Reset distance changed
                        distance_changed = 0;
                    else
                        % Add pose if robot travelled certain distance
                        d = sqrt((c_packet.pose.x - p_packet.pose.x)^2 ...
                            + (c_packet.pose.y - p_packet.pose.y)^2);
                        distance_changed = distance_changed + d;
                        if (distance_changed > min_distance)
                            % Combine lidar scan and subsample it
                            % This will give a bigger map for better scan
                            % matching
                            packet_ids = ...
                                (i_packet - n_combine):(i_packet + n_combine);
                            gscan = extract_scan(c_robot.packet(packet_ids));
                            % Append this node to the graph
                            obj.pnode(end+1) = PoseNode(id, pose, t, gscan);
                            % reset distance changed
                            distance_changed = 0;
                        end
                    end
                    p_packet = c_packet;
                end  % for each packet
            end  % for each robot
        end  % genNode
        
        %%%
        %> @brief generates graph based on odometry and scan matching
        %%%
        function genGraph(obj)
            
        end
        
        %%%
        %> @brief close loop based on global scan matching
        %%%
        function closeLoop(obj)
            
        end
        
        function n_node = get.n_node(obj)
            n_node = numel(obj.pnode);
        end
        
    end  % methods
    
end  % classdef

%%%
%> @brief extract and combine scans from multiple packet
%> @param packet input packets
%> @return gscan combined laser scans in world frame
%%%
function gscan = extract_scan(packet)
% Initialize a big enough gscan
n_packet = numel(packet);
gscan = zeros(2,n_packet*1000);

k = 0;
for i_packet = 1:n_packet
    n = numel(packet{i_packet}.hlidar.xs);
    gscan(:,k+1:k+n) = ...
        [packet{i_packet}.hlidar.xs';
        packet{i_packet}.hlidar.ys'];
    k = k + n;
end

gscan = double(gscan(:,1:ceil(n_packet/1.5):k));

end