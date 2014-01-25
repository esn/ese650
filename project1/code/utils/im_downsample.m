function [ im_out ] = im_downsample( im_orig, scale )
%IM_DOWNSAMPLE Down sample an image
%   [ im_out ] = im_downsample( im_orig, scale )

if scale == 1
    im_out = im;
else
    im_out = imresize(im_orig, 1/scale);
end

end