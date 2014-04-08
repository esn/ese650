function [ f ] = edge_feature( im )
%EDGE_FEATURE

[nr,nc,~] = size(im);
img = rgb2gray(im);
e = edge(img, 'canny', 0.5);
f = reshape(e, nr*nc, []);

end

