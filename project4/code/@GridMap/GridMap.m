classdef GridMap < handle
    %GRIDMAP
    
    properties
        map       % 2d occupancy grid map
        rgb       % rgb image
        xy_bound  % [xmin xmax ymin ymax]
        z_bound   % [zmin zmax]
        res
        dim       % [xdim ydim]
        h_map
        h_car
    end
    
    methods
        function GM = GridMap(xy_bound, res, z_bound)
            GM.res = res;
            GM.xy_bound = xy_bound(:);
            GM.z_bound = z_bound;
            GM.dim = ceil((GM.xy_bound([2 4]) - GM.xy_bound([1 3])) ./ GM.res);
            GM.map = zeros(GM.dim(2), GM.dim(1));
            GM.rgb = zeros(GM.dim(2), GM.dim(1), 3, 'uint8');
        end
        
        function plot(GM)
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
        
        function sub = pos2sub(GM, pos)
            pos = pos(1:2,:);
            sub = bsxfun(@min, bsxfun(@max, ceil(bsxfun(@minus, pos, GM.xy_bound([1 3]))./GM.res), ones(2,1)), GM.dim);
        end
        
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
            [sub_clear_row, sub_clear_col] = getMapCellsFromRay(sub_robot(1), sub_robot(2), ...
                sub_occupy(1,:), sub_occupy(2,:));
            GM.update_map_sub(sub_occupy, 1);
            GM.update_map_sub([sub_clear_row'; sub_clear_col'], -1);
        end
    end
    
end