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
        emeans  %> 3 x 3 x n matrix
        einfms  %> 3 x 3 x n matrix
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
        %> @param robot Variable from log.mat
        %> @param min_dist Minimum distance travelled to be added
        %> @param n_comb Number of packet to combine around current one
        %%%
        function genNode(obj, robot, min_dist, n_comb)
            if nargin < 4, n_comb = 25; end
            if nargin < 3, min_dist = 2.5; end
            
            obj.n_robot = numel(robot);
            start_packet = n_comb + 1;
            for i_robot = 1:obj.n_robot
                fprintf('Generating node for robot %d.\n', i_robot);
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
                        gscan = merge_scan({c_packet});
                        % Add 1st pose of each robot to node list
                        obj.pnode(end+1) = PoseNode(id, pose, t, gscan);
                        % Reset distance changed
                        distance_changed = 0;
                    else
                        % Add pose if robot travelled certain distance
                        d = sqrt((c_packet.pose.x - p_packet.pose.x)^2 ...
                            + (c_packet.pose.y - p_packet.pose.y)^2);
                        distance_changed = distance_changed + d;
                        if (distance_changed > min_dist)
                            % Combine lidar scan and subsample it
                            % This will give a bigger map for better scan
                            % matching
                            packet_ids = ...
                                (i_packet - n_comb):(i_packet + n_comb);
                            gscan = merge_scan(c_robot.packet(packet_ids));
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
        %> @param n_iter Number of iteration to optimizae
        %%%
        function optimize(obj, n_iter)
            for i_iter = 1:n_iter
                fprintf('Pose Graph Optimization, Iteration %d.\n', i_iter);
                obj.iterate();
                fprintf('Iteration %d done.\n', i_iter);
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
        end
        
        %%%
        %> @brief generates graph based on odometry (raw slam)
        %> This step assume fixed covariance and zero error
        %%%
        function linearizeMotion(obj)
            % zhat_ij = xj - xi
            % z_ij    = zij
            % e = zij - zhat_ij
            omega = diag([5 5 10].^2);
            A = -eye(3);
            B = +eye(3);
            
            % anchoring the position of the the first vertex.
            obj.H(1:3,1:3) = obj.H(1:3,1:3) + eye(3);
            
            for i_node = 1:obj.n_node-1
                j_node = i_node + 1;
                curr_id = obj.pnode(i_node).id;
                next_id = obj.pnode(i_node+1).id;
                i_ind = id2ind(i_node);
                j_ind = id2ind(j_node);
                if curr_id ~= next_id
                    % We don't connect between each robots here
                    % but we anchoring the position of the first vertex of
                    % each robot here
                    obj.H(j_ind,j_ind) = obj.H(j_ind,j_ind) + eye(3);
                    continue;
                end
                % Formulate blocks
                H_ii = A' * omega * A;
                H_ij = A' * omega * B;
                H_jj = B' * omega * B;
                % Update H matrix
                obj.H(i_ind,i_ind) = obj.H(i_ind,i_ind) + H_ii;
                obj.H(i_ind,j_ind) = obj.H(i_ind,j_ind) + H_ij;
                obj.H(j_ind,i_ind) = obj.H(j_ind,i_ind) + H_ij';
                obj.H(j_ind,j_ind) = obj.H(j_ind,j_ind) + H_jj;
                % Since there's no odometry, eij will just be zeros
            end  % each node
        end
        
        %%%
        %> @brief generates graph based on measurement (scan match)
        %%%
        function linearizeMeasurement(obj)
            n_edge = size(obj.eids,2);
            for i_edge = 1:n_edge
                i_node = obj.eids(1,i_edge);
                j_node = obj.eids(2,i_edge);
                i_ind  = id2ind(i_node);
                j_ind  = id2ind(j_node);
                omega  = obj.einfms(:,:,i_edge);
                
                v_i = obj.pnode(i_node).pose;
                v_j = obj.pnode(j_node).pose;
                T_z = obj.emeans(:,:,i_edge);
                
                T_i = v2t(v_i);
                T_j = v2t(v_j);
                R_i = T_i(1:2,1:2);
                R_z = T_z(1:2,1:2);
                
                si = sin(v_i(3));
                ci = cos(v_i(3));
                dR_i = [-si ci; -ci -si]';
                dt_ij = v_j(1:2) - v_i(1:2);
                
                % Calculate jacobians
                A = [-R_z'*R_i' R_z'*dR_i'*dt_ij; 0 0 -1];
                B = [R_z'*R_i' [0;0]; 0 0 1];
                
                % Calculate error vector
                e = t2v(inv(T_z) * inv(T_i) * T_j);
                
                % Formulate blocks
                H_ii =  A' * omega * A;
                H_ij =  A' * omega * B;
                H_jj =  B' * omega * B;
                b_i  = -A' * omega * e;
                b_j  = -B' * omega * e;
                
                % Update H and b matrix
                obj.H(i_ind,i_ind) = obj.H(i_ind,i_ind) + H_ii;
                obj.H(i_ind,j_ind) = obj.H(i_ind,j_ind) + H_ij;
                obj.H(j_ind,i_ind) = obj.H(j_ind,i_ind) + H_ij';
                obj.H(j_ind,j_ind) = obj.H(j_ind,j_ind) + H_jj;
                obj.b(i_ind) = obj.b(i_ind) + b_i;
                obj.b(j_ind) = obj.b(j_ind) + b_j;
            end
        end
        
        %%%
        %> @brief solve the linear system and update all pose node
        %%%
        function solve(obj)
            fprintf('Pose: %d, Edge: %d\n', obj.n_node, size(obj.eids,2));
            H_sparse = sparse(obj.H);
            dx = H_sparse \ obj.b;
            dpose = reshape(dx, 3, obj.n_node);
            
            % Update pnode with solution
            for i_node = 1:obj.n_node
                obj.pnode(i_node).pose = obj.pnode(i_node).pose ...
                    + dpose(:,i_node);
            end
        end
        
        %%%
        %> @brief Close loop based on global scan matching
        %> @param d_node   Number of nodes between nodes
        %> @param d_search Search distance
        %%%
        function closeLoop(obj, d_node, d_search, vis)
            if nargin < 4, vis = false; end
            if nargin < 3, d_search = 4; end
            if nargin < 2, d_node = 8; end
            
            % Initialize plot
            if vis
                figure();
                hold on;
                obj.pnode.plot();
                beautify(gcf);
            end
            
            % Initialize variables
            obj.eids = zeros(2,obj.n_node);
            obj.emeans = zeros(3,3,obj.n_node);
            obj.einfms = zeros(3,3,obj.n_node);
            i_edge = 0;
            
            % Starting from a node i
            fprintf('Detecting loop closure.\n');
            for i_node = (d_node+1):obj.n_node
                pnd_i = obj.pnode(i_node);
                % Search in nodes from start to d_node away from i_node
                for j_node = 1:(i_node-d_node)
                    % Calculate the distance from j_node to i_node
                    pnd_j = obj.pnode(j_node);
                    dist = sum((pnd_j.pose(1:2) - pnd_i.pose(1:2)).^2);
                    % Keep node that's within d_search distance
                    if dist < d_search^2
                        % Do scan matching
                        % The result of this match rt, is the same as Zij
                        % which is a rototranslation matrix from j to i
                        [rt, infm, valid] = scan_match(pnd_i, pnd_j);
                        % Add valid loop closure to graph
                        if valid
                            i_edge = i_edge + 1;
                            obj.eids(:,i_edge) = [i_node; j_node];
                            obj.emeans(:,:,i_edge) = rt;
                            obj.einfms(:,:,i_edge) = infm;
                            if vis
                                plot([pnd_i.pose(1) pnd_j.pose(1)], ...
                                    [pnd_i.pose(2) pnd_j.pose(2)], 'k')
                                drawnow
                            end  % vis
                        end  % valid edge
                    end  % within d_search
                end  % j_node
            end  % i_node
            
            % Truncates variables
            obj.eids   = obj.eids(:,1:i_edge);
            obj.emeans = obj.emeans(:,:,1:i_edge);
            obj.einfms = obj.einfms(:,:,1:i_edge);
            
            fprintf('Detected loop closure: %d.\n', i_edge);
        end  % closeLoop
        
        %%%
        %> @brief Plot graph with edges
        %%%
        function plot(obj)
            if ~isempty(obj.eids)
                for i_edge = 1:size(obj.eids,2)
                    i_node = obj.eids(1,i_edge);
                    j_node = obj.eids(2,i_edge);
                    pnd_i = obj.pnode(i_node);
                    pnd_j = obj.pnode(j_node);
                    plot([pnd_i.pose(1) pnd_j.pose(1)], ...
                        [pnd_i.pose(2) pnd_j.pose(2)], 'k');
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
%> @brief  extract and merge scans from multiple packet
%> @param  packet  input packets
%> @return gscan   combined laser scans in world frame
%%%
function gscan = merge_scan(packet)
% MERGE_SCAN
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


function ind = id2ind(id)
%ID2IND
ind = (3*(id-1)+1):(3*id);
end