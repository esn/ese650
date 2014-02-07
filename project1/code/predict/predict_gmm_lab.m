function [ P_red ] = predict_gmm_lab( data, model )

im_lab = data.lab;
% ab = double(im_lab(:,:,2:3));
ab = double(im_lab);
nrows = size(ab, 1);
ncols = size(ab, 2);
X = reshape(ab, nrows*ncols, 3);

P_red = predict_gmm(X, model);
P_red = reshape(P_red, nrows, ncols);
% P_red = (P_red - min(P_red(:)))/max(P_red(:));

end