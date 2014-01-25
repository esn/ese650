function [ dist ] = get_dist_from_fname( filename )
%GET_DIST_FROM_FNAME Get distance from filename
%   [ dist ] = get_distance( filename )

chars = sscanf(filename, '%d.%d.%s');
dist = chars(1);

end
