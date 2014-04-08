function [ f ] = bin_feature( im )
%BIN_FEATURE

[nr,nc,~] = size(im);
cl = color_detection_by_hue(im);
f_r = cl.red;
f_g = cl.green;
f_b = cl.blue;
f_y = cl.yellow;


f_r = reshape(f_r, nr*nc, []);
f_g = reshape(f_g, nr*nc, []);
f_b = reshape(f_b, nr*nc, []);
f_y = reshape(f_y, nr*nc, []);

f = [f_r f_g f_b f_y];

end

