classdef GridMap < handle
    %GRIDMAP
    
    properties
        gray      % 2d occupancy grid map
        rgb       % rgb image
        xy_bound  % [xmin xmax ymin ymax]
        z_bound   % [zmin zmax]
        res
        dim       % [xdim ydim]
    end
    
    methods
        function GM = GridMap(xy_bound, res, z_bound)
            GM.res = res;
            GM.xy_bound = xy_bound;
            GM.z_bound = z_bound;
            GM.dim = ceil((xy_bound([2 4]) - xy_bound([1 3])) ./ res + 1);
            GM.gray = zeros(GM.dim(2), GM.dim(1));
            GM.rgb = zeros(GM.dim(2), GM.dim(1), 3, 'uint8');
        end
    end
    
end