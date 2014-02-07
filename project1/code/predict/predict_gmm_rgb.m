function [ P_red ] = predict_gmm_rgb( data, model )

im_rgb = data.rgb;
rgb = double(im_rgb);
nrows = size(rgb, 1);
ncols = size(rgb, 2);
X = reshape(rgb, nrows*ncols, 3);

P_red = predict_gmm(X, model);
P_red = reshape(P_red, nrows, ncols);
P_red = normalize(P_red);

end

