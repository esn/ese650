function [ f ] = hsv_feature( im )
%HSV_FEATURE 

im = im2double(im);
hsv = rgb2hsv(im);
f = reshape(hsv, size(im,1)*size(im,2), []);

end

