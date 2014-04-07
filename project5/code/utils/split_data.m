clear all
close all

%% Parameters
SAVE = true;
IM_WIDTH = 5000;
SUB_IM_WIDTH = 720;
SUB_IM_HEIGHT = 640;
mat_name = 'mat/data.mat';
im_name = 'mat/rgb.mat';

%% Load image
im_rgb = imread('../data/aerial_color.jpg');
% im_rgb = imread('../data/golf_course.png');
im_rgb = im_rgb(100:end, 1220:end-20, :);
im_rgb = imresize(im_rgb, [nan, IM_WIDTH]);

%% Preprocess image by smoothing
for i = 1:3
    im_rgb(:,:,i) = medfilt2(im_rgb(:,:,i));
end
imshow(im_rgb)

%% Split image
sub = cell(0);
k = 0;
[nr, nc, ~] = size(im_rgb);
nr = floor(nr/SUB_IM_HEIGHT);
nc = floor(nc/SUB_IM_WIDTH);
for r = 1:nr
    for c = 1:nc
        k = k + 1;
        sub{k} = im_rgb(SUB_IM_HEIGHT*(r-1)+1:SUB_IM_HEIGHT*r, ...
            SUB_IM_WIDTH*(c-1)+1:SUB_IM_WIDTH*c,:);
        subplot(nr,nc,k)
        imshow(sub{k})
        title(sprintf('sub %d', k))
    end
end

%% save to a struct
if SAVE
    save(mat_name, 'sub');
    save(im_name, 'im_rgb');
    fprintf('Images saved to %s.\n', mat_name);
end