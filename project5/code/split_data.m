clear all
close all

%% Parameters
IM_WIDTH = 5000;
SUB_IM_WIDTH = 600;
SUB_IM_HEIGHT = 600;

%% Load image
im = imread('../data/aerial_color.jpg');
im = im(750:end, 1220:end-20, :);
im = imresize(im, [nan, IM_WIDTH]);
imshow(im);

%% Split image
sub = struct;
k = 0;
[nr, nc, ~] = size(im);
nr = floor(nr/SUB_IM_HEIGHT);
nc = floor(nc/SUB_IM_WIDTH);
for r = 1:nr
    for c = 1:nc
        k = k + 1;
        sub(k).im = im(SUB_IM_HEIGHT*(r-1)+1:SUB_IM_HEIGHT*r, ...
            SUB_IM_WIDTH*(c-1)+1:SUB_IM_WIDTH*c,:);
        subplot(nr,nc,k)
        imshow(sub(k).im)
        title(sprintf('sub %d', k))
    end
end
