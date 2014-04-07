function [ f ] = rgb_feature( im )
%RGB_FEATURE convert image to rgb feature

f = im2double(im);
f = reshape(f, size(im,1)*size(im,2), []);

end

