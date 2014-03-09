function [ n ] = vec2norm( x, dim )
%VEC2NORM calculates 2-norm of vectors along the specified dimension
% [ n ] = vec2norm( x, dim )
n = sqrt(sum(x.^2, dim));
end