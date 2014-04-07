function [ f ] = bw_feature( im )
%BW_FEATURE 

[nr,nc,~] = size(im);
img = im2double(rgb2gray(im));
mu = 0.08;
sigma = 1;
P_b = normpdf(img(:), mu, sigma);
P_w = normpdf(img(:), 1-mu, sigma);
f_b = reshape(P_b, nr*nc, []);
f_w = reshape(P_w, nr*nc, []);
f = [f_b, f_w];

end

