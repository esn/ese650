classdef GraphSlam < handle
    %GRAPHSLAM
    
    properties
        pnode
        iter
        Omega
        xi
    end
    
    properties (Dependent = true)
        num_nodes
    end
    
    methods
        %
        % Constructor
        %
        function obj = GraphSlam(iter)
            obj.iter  = iter;
        end
        
        %
        % genNode
        %
        function genNode(obj, robot, min_pose_dist)
            if nargin < 3, min_pose_dist = 10; end
            % Initialize an empty PoseNode
            obj.pnode = PoseNode.empty;
            num_robot = numel(robot);
            for i_robot = 1:num_robot
                num_packet = numel(robot{i_robot}.packet);
                for i_packet = 1:num_packet
                    curr_packet = robot{i_robot}.packet{i_packet};
                    if i_packet == 1
                        % Add 1st pose of each robot to node list
                        obj.pnode(end+1) = PoseNode(curr_packet);
                        travel_dist = 0;
                    else
                        % Add pose if robot travelled certain distance
                        d = sqrt((curr_packet.pose.x - prev_packet.pose.x)^2 ...
                            + (curr_packet.pose.y - prev_packet.pose.y)^2);
                        travel_dist = travel_dist + d;
                        if travel_dist > min_pose_dist
                            obj.pnode(end+1) = PoseNode(curr_packet);
                            % reset travel dist
                            travel_dist = 0;
                        end
                    end
                    prev_packet = curr_packet;
                end  % for each packet
            end  % for each robot
        end
        
        %
        % linearize
        %
        function linearize(obj)
            
        end
        
        %
        % solve
        %
        function solve(obj)
            
        end
        
        %
        % iterate
        %
        function iterate(obj)
            
        end
        
        %
        % Get Methods
        %
        function num_nodes = get.num_nodes(obj)
            num_nodes = numel(obj.pnode);
        end
    end
    
end
