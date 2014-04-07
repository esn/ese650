clear all
close all

%%
mat_name = 'data.mat';
load(mat_name);

%% transform to different color space
im_rgb = sub{5};

cform = makecform('srgb2lab');
im_lab = applycform(im_rgb, cform);

im_hsv = rgb2hsv(im_rgb);
im_ycbcr = rgb2ycbcr(im_rgb);

figure(1)
subplot(2,2,1)
imshow(im_rgb)
title('rgb')

subplot(2,2,2)
imshow(im_hsv)
title('hsv')

subplot(2,2,3)
imshow(im_ycbcr)
title('ycbcr')

subplot(2,2,4)
imshow(im_lab)
title('lab')

%% Detect black and write
figure()
img = rgb2gray(im_rgb);
img = im2double(img);
mu = 0.08;
sigma = 0.1;
P_b = normpdf(img(:), mu, sigma);
imagesc(reshape(P_b, size(img,1), size(img,2)))


