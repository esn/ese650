classdef GridMap < handle
    %GRIDMAP
    
    properties
        map       % 2d occupancy grid map
        rgb       % rgb image
        xy_bound  % [xmin xmax ymin ymax]
        z_bound   % [zmin zmax]
        res
        dim       % [xdim ydim]
        z_coeff
        
        k = 0
        l = 0.3
        s
        t
        s_hist
        t_hist
        
        h_map
        h_car
        h_traj
        h_lidar_orig
        h_lidar_corr
        h_title
        h_p
    end
    
    methods
        % Constructor
        function GM = GridMap(xy_bound, res, z_bound, max_len)
            if nargin < 4, max_len = 5000; end
            GM.res = res;
            
            if numel(xy_bound) == 1, xy_bound = [-1;1;-1;1] * xy_bound; end
            GM.xy_bound = xy_bound(:);
            
            if z_bound < 1, z_bound = log(z_bound/(1-z_bound)); end
            GM.z_bound = ceil(z_bound);
            GM.dim = ceil((GM.xy_bound([2 4]) - GM.xy_bound([1 3])) ./ GM.res + 1);
            GM.map = zeros(GM.dim(2), GM.dim(1), 'int8');
            
            GM.z_coeff = 255/2/GM.z_bound;
            
            GM.l = GM.l / GM.res;
            GM.s_hist = zeros(3,max_len);
            GM.t_hist = zeros(1,max_len);
        end
        
        % Utils methods
        function sub = pos2sub(GM, pos)
            pos = pos(1:2,:);
            sub = bsxfun(@min, bsxfun(@max, ...
                round(bsxfun(@minus, pos, GM.xy_bound([1 3]))./GM.res), ...
                ones(2,1)), GM.dim);
        end
        
        function p = world2map(GM, p)
            p(1,:) = (p(1,:) + GM.xy_bound(2))./GM.res;
            p(2,:) = (p(2,:) + GM.xy_bound(4))./GM.res;
        end
        
        % Updating methods
        function update_map_pos(GM, pos, dz)
            sub = GM.pos2sub(pos);
            GM.update_map_sub(sub, dz);
        end
        
        function update_map_sub(GM, sub, dz)
            ind = sub2ind(GM.dim, sub(2,:), sub(1,:));
            GM.map(ind) = GM.map(ind) + dz * GM.z_coeff;
        end
        
        function update_map(GM, s, p_range, dz, t)
            sub_robot = GM.pos2sub(s);
            sub_occupy = GM.pos2sub(p_range);
            [sub_clear_row, sub_clear_col] = ...
                getMapCellsFromRay(sub_robot(1), sub_robot(2), ...
                sub_occupy(1,:), sub_occupy(2,:));
            sub_clear = [sub_clear_row'; sub_clear_col'];
            
            GM.update_map_sub(sub_clear, dz(2));
            GM.update_map_sub(sub_occupy, dz(1));
            
            GM.k = GM.k + 1;
            GM.s = GM.world2map(s);
            GM.s_hist(:,GM.k) = GM.s;
            GM.t = t;
            GM.t_hist(:,GM.k) = GM.t;
        end
        
        function truncate_hist(GM)
            GM.t_hist = GM.t_hist(1:GM.k);
            GM.s_hist = GM.s_hist(:,1:GM.k);
        end
        
        % Visualization methods
        function plot_map(GM)
            if isempty(GM.h_map)
                GM.h_map = imshow(-GM.map, 'InitialMagnification', 'fit');
                GM.h_title = title(sprintf('t=%.4f', GM.t - GM.t_hist(1)));
                set(gca, 'Visible', 'On');
                axis equal;
                axis tight;
                axis xy;
            else
                set(GM.h_map, 'CData', -GM.map);
                set(GM.h_title, 'String', ...
                    sprintf('t=%.4f', GM.t - GM.t_hist(1)));
            end
        end
        
        function plot_car(GM, varargin)
            if isempty(GM.h_car)
                hold on
                GM.h_car(1) = plot(GM.s(1), GM.s(2), varargin{:});
                GM.h_car(2) = plot([GM.s(1), GM.s(1) + GM.l * cos(GM.s(3))], ...
                    [GM.s(2), GM.s(2) + GM.l * sin(GM.s(3))], '-');
                hold off
            else
                set(GM.h_car(1), 'XData', GM.s(1), 'YData', GM.s(2));
                set(GM.h_car(2), ...
                    'XData', [GM.s(1), GM.s(1) + GM.l * cos(GM.s(3))], ...
                    'YData', [GM.s(2), GM.s(2) + GM.l * sin(GM.s(3))]);
            end
            
        end
        
        function plot_traj(GM, varargin)
            if isempty(GM.h_traj)
                hold on
                GM.h_traj = plot(GM.s_hist(1,1:GM.k), ...
                    GM.s_hist(2,1:GM.k), varargin{:});
                hold off
            else
                set(GM.h_traj, ...
                    'XData', GM.s_hist(1,1:GM.k), ...
                    'YData', GM.s_hist(2,1:GM.k));
            end
            
        end
        
        function plot_lidar_orig(GM, p_range, varargin)
            p_range = GM.world2map(p_range(1:2,:));
            if isempty(GM.h_lidar_orig)
                hold on
                GM.h_lidar_orig = plot(p_range(1,:), p_range(2,:), ...
                    varargin{:});
                hold off
            else
                set(GM.h_lidar_orig, ...
                    'XData', p_range(1,:), ...
                    'YData', p_range(2,:));
            end
        end
        
        function plot_lidar_corr(GM, p_range, varargin)
            p_range = GM.world2map(p_range(1:2,:));
            if isempty(GM.h_lidar_corr)
                hold on
                GM.h_lidar_corr = plot(p_range(1,:), p_range(2,:), ...
                    varargin{:});
                hold off
            else
                set(GM.h_lidar_corr, ...
                    'XData', p_range(1,:), ...
                    'YData', p_range(2,:));
            end
        end
        
        function plot_particle(GM, p, varargin)
            p = GM.world2map(p);
            if isempty(GM.h_p)
                hold on
                GM.h_p(1) = plot(p(1,:), p(2,:), varargin{:});
                GM.h_p(2) = quiver(p(1,:), p(2,:), ...
                    GM.l * cos(p(3,:)), ...
                    GM.l * sin(p(3,:)), 0,  'Color', 'r');
                hold off
            else
                set(GM.h_p(1), 'XData', p(1,:), 'YData', p(2,:));
                set(GM.h_p(2), ...
                    'XData', p(1,:), 'YData', p(2,:), ...
                    'UData', GM.l * cos(p(3,:)), ...
                    'VData', GM.l * sin(p(3,:)));
            end            
        end
    end
    
end