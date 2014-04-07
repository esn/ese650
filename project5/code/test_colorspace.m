clear all
close all

%% 
mat_name = 'data.mat';
load(mat_name);

%% transform to different color space
im_rgb = sub{8};

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
bw = rgb2gray(im_rgb) > 230;
black_im = zeros(size(im_rgb), 'uint8');
for i = 1:3
    temp = im_rgb(:,:,i);
    temp(bw) = 0;
    black_im(:,:,i) = temp;
end
    
imshow(black_im)
