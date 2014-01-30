data = train;
i = 21;
im_lab = data(i).lab;
im_rgb = data(i).im;
area_thresh = 120;
lum_thresh = 100;
ab = double(im_lab(:,:,2:3));
nrows = size(ab, 1);
ncols = size(ab, 2);
ab = reshape(ab, nrows*ncols, 2);
L = double(im_lab(:,:,1));
L = median(L(:));

if L > lum_thresh
    barrel = [190, 150];
else
    barrel = [160, 140];
end

figure()

num_cluster = 4;
[cluster_idx, cluster_center] = ...
    kmeans(ab, num_cluster, 'distance', 'sqEuclidean', 'emptyaction', 'singleton', 'Replicates', 5);
pixel_labels = reshape(cluster_idx, nrows, ncols);
subplot(1,2,1)
imshow(im_rgb)
title('Original image')
subplot(1,2,2)
imshow(pixel_labels, []);
title(sprintf('k = %d, image labeled by cluster index', num_cluster));
[val, ind] = min(abs(cluster_center(:,1) - barrel(1)));
bw = pixel_labels == ind;

figure(2)
subplot(1,2,1)
imshow(bw)
title('Pixels from Kmeans')
subplot(1,2,2)
seD = strel('diamond', 1);
bw = bwareaopen(bw, area_thresh); % remove anything with area less than 50
bw = imfill(bw, 'holes');
imshow(bw)

cc = bwconncomp(bw);
rp = regionprops(cc, 'Area', 'BoundingBox', 'Centroid', 'MajorAxisLength', 'MinorAxisLength');
hold on
for i = 1:length(rp)
    plot(rp(i).Centroid(1), rp(i).Centroid(2), 'r+', 'MarkerSize', 8, 'LineWidth', 2)
    rectangle('Position', rp(i).BoundingBox, 'EdgeColor', 'g', 'LineWidth', 2)
    if i == 3
    rectangle('Position', rp(i).BoundingBox, 'EdgeColor', 'm', 'LineWidth', 2)
    end
end
hold off
title('Barrel Candidates')