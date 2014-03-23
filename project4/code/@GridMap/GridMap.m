classdef GridMap < handle
    %GRIDMAP
    
    properties
        map       % 2d occupancy grid map
        rgb       % rgb image
        xy_bound  % [xmin xmax ymin ymax]
        z_bound   % [zmin zmax]
        res
        dim       % [xdim ydim]
        
        k = 0;
        l
        s
        s_hist
        
        h_map
        h_car
        h_traj
    end
    
    methods
        % Constructor
        function GM = GridMap(xy_bound, res, z_bound)
            GM.res = res;
            GM.xy_bound = xy_bound(:);
            GM.z_bound = z_bound;
            GM.dim = ceil((GM.xy_bound([2 4]) - GM.xy_bound([1 3])) ./ GM.res);
            GM.map = zeros(GM.dim(2), GM.dim(1));
            GM.rgb = zeros(GM.dim(2), GM.dim(1), 3, 'uint8');
            GM.l = 0.3 / GM.res;
        end
        
        % Visualization methods
        function plot_map(GM)
            im2disp = uint8((-GM.map + GM.z_bound)/2/GM.z_bound*255);
            if isempty(GM.h_map)
                GM.h_map = imshow(im2disp, 'InitialMagnification', 'fit');
                set(gca, 'Visible', 'On');
                axis equal;
                axis tight;
                axis xy;
            else
                set(GM.h_map, 'CData', im2disp);
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
            drawnow
        end
        
        function plot_traj(GM, varargin)
            if isempty(GM.h_traj)
                hold on
                GM.h_traj = plot(GM.s_hist(1,1:GM.k), GM.s_hist(2,1:GM.k), varargin{:});
                hold off
            else
                set(GM.h_traj, ...
                    'XData', GM.s_hist(1,1:GM.k), ...
                    'YData', GM.s_hist(2,1:GM.k));
            end
            drawnow
        end
        
        % Utils methods
        function sub = pos2sub(GM, pos)
            pos = pos(1:2,:);
            sub = bsxfun(@min, bsxfun(@max, ceil(bsxfun(@minus, pos, GM.xy_bound([1 3]))./GM.res), ones(2,1)), GM.dim);
        end
        
        function s = world2map(GM, s)
            s(1) = (s(1) + GM.xy_bound(2))./GM.res;
            s(2) = (s(2) + GM.xy_bound(4))./GM.res;
        end
        
        % Updating methods
        function update_map_pos(GM, pos, dz)
            sub = GM.pos2sub(pos);
            GM.update_map_sub(sub, dz);
        end
        
        function update_map_sub(GM, sub, dz)
            ind = sub2ind(GM.dim, sub(2,:), sub(1,:));
            GM.map(ind) = GM.map(ind) + dz;
            GM.map = min(GM.map, GM.z_bound);
            GM.map = max(GM.map, -GM.z_bound);
        end
        
        function update_map(GM, s, pos)
            sub_robot = GM.pos2sub(s);
            sub_occupy = GM.pos2sub(pos);
            [sub_clear_row, sub_clear_col] = ...
                getMapCellsFromRay(sub_robot(1), sub_robot(2), ...
                sub_occupy(1,:), sub_occupy(2,:));
            GM.update_map_sub(sub_occupy, 1);
            GM.update_map_sub([sub_clear_row'; sub_clear_col'], -1);
            GM.k = GM.k + 1;
            GM.s = GM.world2map(s);
            GM.s_hist(:,GM.k) = GM.s;
        end
    end
    
end