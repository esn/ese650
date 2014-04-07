function [ f ] = lab_feature( im )
%LAB_FEATURE 
im = im2double(im);
cform = makecform('srgb2lab');
lab = applycform(im, cform);
f = lab(:,:,2:3);
f = reshape(f, size(im,1)*size(im,2), []);

end

