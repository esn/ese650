im = train(1).im;
figure(1)
subplot(1,2,1)
imshow(im)

cform = makecform('srgb2lab');
lab_im = applycform(im, cform);

ab = double(lab_im(:,:,2:3));
% ab = double(lab_im);
nrows = size(ab, 1);
ncols = size(ab, 2);
ab = reshape(ab, nrows*ncols, 2);

nColors = 8;
% repeat the clustering 3 times to avoid local minima
[cluster_idx cluster_center] = ...
    kmeans(ab,nColors, 'distance', 'sqEuclidean', 'Replicates', 8);
pixel_labels = reshape(cluster_idx,nrows,ncols);

subplot(1,2,2)
imshow(pixel_labels,[]), title('image labeled by cluster index');