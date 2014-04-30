%%%
%> @file GraphSlam.m
%> @brief A class for doing pose graph optimization
%%%
classdef GraphSlam < handle
    
    properties
        n_iter  %> Number of iterations to run optimization
        pnode   %> Pose nodes added to graph
        H       %> Information matrix
        b       %> Information vector
        n_robot %> Number of robots
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
        function obj = GraphSlam(n_iter)
            obj.n_iter = n_iter;
            obj.pnode  = PoseNode.empty;
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

            obj.n_robot = numel(robot);
            start_packet = n_combine + 1;
            for i_robot = 1:obj.n_robot
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
        %> @brief pose graph optimization
        %%%
        function optimize(obj)
            for i_iter = 1:obj.n_iter
                fprintf('Pose Graph Optimization, Iteration %d.\n', i_iter);
                obj.solve();
            end
        end
        
        %%%
        %> @brief linearize and solve graph
        %%%
        function solve(obj)
            fprintf('Allocating Workspace.\n');
            obj.H = zeros(obj.n_node*3);   % 3n x 3n square matrix
            obj.b = zeros(obj.n_node*3,1); % 3n x 1  column vector
            
            fprintf('Linearizing motion.\n');
            obj.linearizeMotion();
            
            fprintf('Linearizing measurement.\n');
            obj.closeLoop();  % Finds connecting edge
            obj.linearizeMeasurement();
        end
        
        %%%
        %> @brief generates graph based on odometry (raw slam)
        %> This step assume fixed covariance and zero error
        %%%
        function linearizeMotion(obj)
            % zhat_ij = xj - xi
            % z_ij    = zij
            % e = zij - zhat_ij
            Omg = diag([5 5 10].^2);
            A = -eye(3);
            B = +eye(3);
            
            for i_node = 1:obj.n_node-1
                curr_id = obj.pnode(i_node).id;
                next_id = obj.pnode(i_node+1).id;
                i_ind = (3*(i_node-1)+1):(3*i_node);
                j_ind = (3*i_node+1):(3*(i_node+1));
                if curr_id ~= next_id
                    % We don't connect between robots here
                    continue;
                end
                obj.H(i_ind,i_ind) = A' * Omg * A;
                obj.H(i_ind,j_ind) = A' * Omg * B;
                obj.H(j_ind,i_ind) = B' * Omg * A;
                obj.H(j_ind,j_ind) = B' * Omg * B;
                % Since there's no odometry, eij will just be zeros
            end  % each node
        end
        
        
        
        %%%
        %> @brief generates graph based on measurement (scan match)
        %%%
        function linearizeMeasurement(obj)
            
        end
            
        %%%
        %> @brief close loop based on global scan matching
        %> @param d_node number of nodes between nodes
        %> @param d_search search distance
        %> @return eids 2 x n matrix [id_from, id_to]
        %> @return emeans 3 xn matrix [x, y, theta]
        %%%
        function [eids, emeans] = closeLoop(obj, d_node, d_search)
            if nargin < 3, d_search = 5; end
            if nargin < 2, d_node = 3; end
            for i_node = 1:obj.n_node
                
            end
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
% Assume 1000 scans in each packet
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

%%%
%> @brief computes the homogeneous transformation A of the pose vector v
%> @param v pose vector
%> @return A homogeneous transformation
%> @authro Giorgio Grisetti
%%%
function A = v2t(v)
c = cos(v(3));
s = sin(v(3));
A = [c, -s, v(1);
     s,  c, v(2);
     0   0  1];
end