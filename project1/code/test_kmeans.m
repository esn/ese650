data = train;

im_lab = data(39).lab;
area_thresh = 81;
lum_thresh = 100;
ab = double(im_lab(:,:,2:3));
nrows = size(ab, 1);
ncols = size(ab, 2);
ab = reshape(ab, nrows*ncols, 2);
L = double(im_lab(:,:,1));
L = median(L(:));

if L < lum_thresh
    barrel = [190, 150];
else
    barrel = [160, 140];
end

figure()

num_cluster = 4;
[cluster_idx, cluster_center] = ...
    kmeans(ab, num_cluster, 'distance', 'sqEuclidean', 'emptyaction', 'singleton', 'start', 'cluster', 'Replicates', 5);
pixel_labels = reshape(cluster_idx, nrows, ncols);
subplot(2,2,1)
imshow(pixel_labels, []);
title(sprintf('k = %d, image labeled by cluster index', num_cluster));
[val, ind] = min(sum(bsxfun(@minus, cluster_center, barrel).^2,2));
bw = pixel_labels == ind;
subplot(2,2,2)
imshow(bw)
subplot(2,2,3)
bw = bwareaopen(bw, area_thresh); % remove anything with area less than 50
bw = imfill(bw, 'holes');
imshow(bw)
