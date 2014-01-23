function [ dist ] = get_distance( filename )
%GET_DISTANCE Extract distance from filename
%   [ dist ] = get_distance( filename )

chars = sscanf(filename, '%d.%d.%s');
dist = chars(1);

end
