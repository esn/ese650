classdef Hokuyo
    
    
    properties
        bTs = [133.23 0 514.35]/1000;
        
        h_ldr
        a_bound
        r_bound
        h_bound
    end
    
    methods
        function H = Hokuyo(a_bound, r_bound, h_bound)
            if nargin < 3, h_bound = [-0.5, 3]; end
            if nargin < 2, r_bound = [0.2, 10]; end
            if nargin < 1, a_bound = [-2, 2]; end
            H.a_bound = a_bound;
            H.r_bound = r_bound;
            H.h_bound = h_bound;
        end
        
        % Lidar methods
        function  [p_range, ind] = transform_range(H, s, wRb, range, angle)
            % Prune laser
            [range, angle] = H.prune_lidar_pre(range, angle);
            
            bHs = trans(H.bTs);
            wHb = trans([s(1) s(2) 0]) * [wRb zeros(3,1); zeros(1,3) 1];
            x_range = (range .* cos(H.angle))';
            y_range = (range .* sin(H.angle))';
            p_range = wHb * bHs * [x_range; y_range; zeros(size(x_range)); ones(size(x_range))];
            [p_range, ind] = H.prune_lidar_post(p_range);
        end

        function [range, angle] = prune_lidar_pre(H, range, angle)
            ind = (angle > H.a_bound(1)) & (angle < H.a_bound(2));
        end
        
        function [p_range, ind] = prune_lidar_post(H, p_range)
            
        end
        
    end
end