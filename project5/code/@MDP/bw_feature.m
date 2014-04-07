function [ f ] = bw_feature( im )
%BW_FEATURE 

[nr,nc,~] = size(im);
img = rgb2gray(im);
white = img > 230;
black = img < 25;
fw = reshape(white, nr*nc, []);
fb = reshape(black, nr*nc, []);
f = [fb, fw];

end

