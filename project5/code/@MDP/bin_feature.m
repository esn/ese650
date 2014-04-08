function [ f ] = bin_feature( im )
%BIN_FEATURE

[nr,nc,~] = size(im);
cl = color_detection_by_hue(im);
f_r = cl.red;
f_g = cl.green;
f_k = cl.black;
f_w = cl.white;

f_r = reshape(f_r, nr*nc, []);
f_g = reshape(f_g, nr*nc, []);
f_k = reshape(f_k, nr*nc, []);
f_w = reshape(f_w, nr*nc, []);

f = [f_r f_g f_k f_w];
end

