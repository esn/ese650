classdef Hokuyo < handle
    
    properties (Constant)
        bTs = [133.23 0 514.35]/1000;
    end
    
    properties
        
        
        h_ldr
        a_bound  % angle bound
        r_bound  % range bound
        h_bound  % height bound
        
        step = 4;
        range
        angle
        p_range
        ind
        
        p00 = 0.85
        p11 = 0.8
        dz
        
        h_range
    end
    
    methods
        function H = Hokuyo(angle, a_bound, r_bound, h_bound)
            if nargin < 4, h_bound = [-0.2, 3]; end
            if nargin < 3, r_bound = [0.3, 7]; end
            if nargin < 2, a_bound = [-2.25, 2.25]; end
            H.a_bound = a_bound;
            H.r_bound = r_bound;
            H.h_bound = h_bound;
            H.angle = angle(1:H.step:end); % subsample
            H.dz(1) = log(H.p11/(1 - H.p00))/2;  % occupy
            H.dz(2) = log((1 - H.p11)/H.p00)/3;  % clear
        end
        
        % Lidar methods
        function store_range(H, range)
            H.range = range(1:H.step:end);
        end
        
        % transfomr_range transform range readings into world
        % coordinates xyz based on imu orientation
        function  p_range = transform_range(H, s, eul)
            % transform range to world frame
            bHs = trans(H.bTs);
            wRb = rpy2wrb_xyz(eul);
            wHb = trans([s(1) s(2) 0]) * ...
                [wRb zeros(3,1); zeros(1,3) 1];
            x_range = (H.range .* cos(H.angle))';
            y_range = (H.range .* sin(H.angle))';
            p_range = wHb * bHs * ...
                [x_range; ...
                y_range; ...
                zeros(size(x_range)); ...
                ones(size(x_range))];
            H.p_range = p_range(1:3,:);
        end
        
        % prune_range does the following thing
        % 1. keep all readings within r_bound
        % 2. keep all readings within a_bound
        % 3. keep all readings within z_bound
        function prune_range(H)
            good_ind = (H.range > H.r_bound(1)) & ...
                (H.range < H.r_bound(2));
            good_ind = good_ind & ...
                ((H.angle > H.a_bound(1)) & ...
                (H.angle < H.a_bound(2)));
%             good_ind = good_ind & ...
%                 ((H.p_range(3,:)' > H.h_bound(1)) & ...
%                 (H.p_range(3,:)' < H.h_bound(2)));
            H.p_range = H.p_range(:,good_ind);
            H.ind = good_ind;
        end
        
        % Visualization methods
        function plot_range(H, varargin)
            if isempty(H.h_range)
                H.h_range = plot3(...
                    H.p_range(1,:), ...
                    H.p_range(2,:), ...
                    H.p_range(3,:), varargin{:});
            else
                set(H.h_range, ...
                    'XData', H.p_range(1,:), ...
                    'YData', H.p_range(2,:), ...
                    'ZData', H.p_range(3,:));
            end
        end
    end
    
end