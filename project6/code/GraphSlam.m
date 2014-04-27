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
        %> @param min_dist minimum distance travelled to be added to graph
        %> @param n_comb number of packet to combine around current one
        %%%
        function genNode(obj, robot, min_dist, n_comb)
            if nargin < 4, n_comb = 2; end
            if nargin < 3, min_dist = 2.5; end
            % Initialize an empty PoseNode
            obj.pnode = PoseNode.empty;
            n_robot = numel(robot);
            start_packet = n_comb + 1;
            for i_robot = 1:n_robot
                c_robot = robot{i_robot};
                n_packet = numel(c_robot.packet);
                for i_packet = start_packet:(n_packet - start_packet)
                    % Extract current packet and it's information
                    c_packet = c_robot.packet{i_packet};
                    id = c_packet.id;
                    pose = [c_packet.pose.x;
                            c_packet.pose.y;
                            c_packet.pose.yaw];
                    t = c_packet.pose.gps.t;
                    
                    % Combine lidar scan and subsample it
                    gscan = [];
                    for i = (i_packet - n_comb):(i_packet + n_comb)
                        gscan = [gscan [c_robot.packet{i}.hlidar.xs';
                                        c_robot.packet{i}.hlidar.ys']];
                    end
                    gscan = double(gscan(:,1:2*n_comb+1:end));
                    
                    if i_packet == start_packet;
                        % Add 1st pose of each robot to node list
                        obj.pnode(end+1) = PoseNode(id, pose, t, gscan);
                        dist_changed  = 0;
                    else
                        % Add pose if robot travelled certain distance
                        d = sqrt((c_packet.pose.x - prev_packet.pose.x)^2 ...
                            + (c_packet.pose.y - prev_packet.pose.y)^2);
                        dist_changed = dist_changed + d;
                        if (dist_changed > min_dist)
                            obj.pnode(end+1) = PoseNode(id, pose, t, gscan);
                            % reset value changed to 0
                            dist_changed  = 0;
                        end
                    end
                    prev_packet = c_packet;
                end  % for each packet
            end  % for each robot
        end  % genNode
        
        function n_node = get.n_node(obj)
            n_node = numel(obj.pnode);
        end
        
    end  % methods
    
end
