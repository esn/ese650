%%%
%> @file  GraphSlam.m
%> @brief A class for doing pose graph optimization
%%%
classdef GraphSlam < handle
    
    properties
        pnode   %> Pose nodes added to graph
        H       %> Information matrix
        b       %> Information vector
        n_robot %> Number of robots
        eids    %> 2 x n matrix [id_from, id_to] 
        emeans  %> 3 xn matrix [x, y, theta]
    end
    
    properties (Dependent = true)
        n_node  %> Number of pose nodes in graph
        vertex  %> All poses from nodes
    end
    
    methods
        %%%
        %> @brief Class constructor
        %> Instantiates an object of GraphSlam
        %>
        %> @return instance of the GraphSlam class
        %%%
        function obj = GraphSlam()
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
        function optimize(obj, n_iter)
            for i_iter = 1:n_iter
                fprintf('Pose Graph Optimization, Iteration %d.\n', i_iter);
                obj.iterate();
            end
        end
        
        %%%
        %> @brief one iteration of linearization and solving
        %%%
        function iterate(obj)
            fprintf('Allocating Workspace.\n');
            % Create new H and b matrices each time
            obj.H = zeros(obj.n_node*3);   % 3n x 3n square matrix
            obj.b = zeros(obj.n_node*3,1); % 3n x 1  column vector
            
            fprintf('Linearizing motion.\n');
            obj.linearizeMotion();
            
            fprintf('Linearizing measurement.\n');
            obj.linearizeMeasurement();
            
            fprintf('Solving.\n');
            obj.solve();
            
            fprintf('Iteration done.\n');
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
            
            % anchoring the position of the the first vertex.
            obj.H(1:3,1:3) = obj.H(1:3,1:3) + eye(3);
            
            for i_node = 1:obj.n_node-1
                curr_id = obj.pnode(i_node).id;
                next_id = obj.pnode(i_node+1).id;
                i_ind = (3*(i_node-1)+1):(3*i_node);
                j_ind = (3*i_node+1):(3*(i_node+1));
                if curr_id ~= next_id
                    % We don't connect between each robots here
                    % but we anchoring the position of the first vertex of 
                    % each robot here
                    obj.H(j_ind,j_ind) = obj.H(j_ind,j_ind) + eye(3);
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
        %> @brief solve the linear system and update all pose node
        %%%
        function solve(obj)
            fprintf('System size: %d x %d.\n', size(obj.H,1), size(obj.H,2));
            H_sparse = sparse(obj.H);
            dx = H_sparse \ obj.b;
            dpose = reshape(dx, 3, obj.n_node);
            
            % Update pnode with solution
            for i_node = 1:obj.n_node
                obj.pnode(i_node).pose = obj.pnode(i_node).pose + dpose(:,i_node);
            end
        end
            
        %%%
        %> @brief close    loop based on global scan matching
        %> @param d_node   number of nodes between nodes
        %> @param d_search search distance
        %%%
        function closeLoop(obj, d_node, d_search)
            figure();
            hold on
            obj.pnode.plot();
            
            if nargin < 3, d_search = 5; end
            if nargin < 2, d_node = 10; end
            % Starting from a node i
            for i_node = (d_node+1):obj.n_node
                pnd_i = obj.pnode(i_node);
                % Search in any node from the start to d_node away from
                % i_node
                for j_node = 1:(i_node-d_node)
                    % Calculate the distance from j_node to i_node
                    pnd_j = obj.pnode(j_node);
                    dist = sum((pnd_j.pose(1:2) - pnd_i.pose(1:2)).^2);
                    % Keep node that's within d_search distance
                    if dist < d_search^2
                        % Do scan matching
                        [rt, infm, valid] = scan_match(pnd_i, pnd_j);
                        if valid
                            plot([pnd_i.pose(1) pnd_j.pose(1)], ...
                                [pnd_i.pose(2) pnd_j.pose(2)], 'k')
                            drawnow
                        end
                    end
                end
            end
        end
            
        function n_node = get.n_node(obj)
            n_node = numel(obj.pnode);
        end
        
        function vertex = get.vertex(obj)
            vertex = [obj.pnode.pose];
        end
            
    end  % methods
    
end  % classdef

%%%
%> @brief  extract and combine scans from multiple packet
%> @param  packet  input packets
%> @return gscan   combined laser scans in world frame
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

% Convert from single to double
gscan = double(gscan(:,1:ceil(n_packet/1.5):k));

end

%%%
%> @brief  computes the homogeneous transformation A of the pose vector v
%> @param  v pose vector
%> @return A homogeneous transformation
%> @author Giorgio Grisetti
%%%
function A = v2t(v)
c = cos(v(3));
s = sin(v(3));
A = [c, -s, v(1);
     s,  c, v(2);
     0   0  1];
end

%%%
%> @brief  computes the pose vector v from an homogeneous transformation A
%> param   A homogeneous transformation
%> return  v pose vector
%> @author Giorgio Grisetti
%%%
function v = t2v(A)
v(1:2,1) = A(1:2,3);
v(3,1) = atan2(A(2,1), A(1,1));
end