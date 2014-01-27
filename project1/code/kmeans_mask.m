function data = kmeans_mask( data, id)
% KMEANS_MASK Use kmeans to create mask for each image
area_thresh = 50;
if nargin < 2, id = 1:length(data); end
for i = 1:length(id)
    j = id(i);
    fprintf('Processing image %d, name %s\n', j, data(j).name);
    im = data(j).im;
    
    figure(1)
    subplot(2,2,1)
    imshow(im)
    lab_im = data(j).lab;
    
    % Extract ab channel
    ab = double(lab_im(:,:,2:3));
    nrows = size(ab, 1);
    ncols = size(ab, 2);
    ab = reshape(ab, nrows*ncols, 2);
    
    % Do kmeans
    for n = 1:3
        num_cluster = n + 4;
        ax(n) = subplot(2,2,n+1);
         % Kmeans
        [cluster_idx, ~] = ...
        kmeans(ab, num_cluster, 'distance', 'sqEuclidean', 'Replicates', 5);
        pixel_labels{n} = reshape(cluster_idx, nrows, ncols);
        imshow(pixel_labels{n}, []);
        title(sprintf('k = %d, image labeled by cluster index', num_cluster)); 
    end
    
    % Select which kmeans to use
    [x, y] = ginput(1);
    x = round(x); y = round(y);
    clicked_ax = gca;
    n = find(ax == clicked_ax);
    num_cluster = n + 3;
    selected_pixel_labels = pixel_labels{n};
    selected_label = selected_pixel_labels(y,x);
    
    % Split each cluster
    seg_bw = (selected_pixel_labels == selected_label);
    seg_bw = bwareaopen(seg_bw, area_thresh); % remove anything with area less than 50
    seg_bw = imfill(seg_bw, 'holes');
    
    seg_im = im;
    rgb_label = repmat(selected_pixel_labels, [1 1 3]);
    seg_im(rgb_label ~= selected_label) = 0;
    
    % Visualize
    figure(2)
    subplot(1,2,1)
    imshow(seg_im);
    title(sprintf('objects in cluster %d', selected_label))
    subplot(1,2,2)
    imshow(seg_bw)
    title(sprintf('objects in cluster %d', selected_label))
    
    % Create mask
    figure(3)
    bw = roipoly(seg_bw);
    
    % Output
    if ~isempty(bw)
        bw = bw & seg_bw;
        imshow(bw);
        title('Done')
        data(j).bw = bw;
        disp('Done')
    else
        disp('Canceled')
        title('Cnaceled')
    end
end