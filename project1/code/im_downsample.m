function [ im_out ] = im_downsample( im_orig, scale )
%IM_DOWNSAMPLE Down sample an image
%   [ im_out ] = im_downsample( im_orig, scale )

im_out = resize(im_orig, scale);

end