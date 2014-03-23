classdef Hokuyo < handle
    
    
    properties
        bTs = [133.23 0 514.35]/1000;
        
        h_ldr
        a_bound  % angle bound
        r_bound  % range bound
        h_bound  % height bound
        
        range
        angle
        p_range
        
        h_range
    end
    
    methods
        function H = Hokuyo(angle, a_bound, r_bound, h_bound)
            if nargin < 4, h_bound = [-0.5, 3]; end
            if nargin < 3, r_bound = [0.2, 10]; end
            if nargin < 2, a_bound = [-2, 2]; end
            H.a_bound = a_bound;
            H.r_bound = r_bound;
            H.h_bound = h_bound;
            H.angle = angle;
        end
        
        % Lidar methods
        function  p_range = transform_range(H, s, wRb, range)
            % Prune laser     
            bHs = trans(H.bTs);
            wHb = trans([s(1) s(2) 0]) * ...
                [wRb zeros(3,1); zeros(1,3) 1];
            x_range = (range .* cos(H.angle))';
            y_range = (range .* sin(H.angle))';
            p_range = wHb * bHs * ...
                [x_range; y_range; zeros(size(x_range)); ...
                 ones(size(x_range))];
            H.range = range;
            H.p_range = p_range;
        end

        
        function [p_range, ind] = prune_range(H)
            
        end
        
        % Visualization methods
        function plot_range(H, varargin)
            if isempty(H.h_range)
                H.h_range = plot3(H.p_range(1,:), H.p_range(2,:), ...
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