function [ bw_barrel, rp_barrel ] = iter_kmeans_lab( data, mu_a, lum_thresh )
if nargin < 3; lum_thresh = 100; end
if nargin < 2; mu_a = [189 158]; end

im = data.im;
lab = data.lab;

% Extract ab channel
ab = double(lab(:,:,2:3));
nrows = size(ab, 1);
ncols = size(ab, 2);
X = reshape(ab, nrows*ncols, 2);
L = double(lab(:,:,1));
L = median(L(:));

% Decide color of red based on luminance level
if L > lum_thresh
    red = mu_a(1);
else
    red = mu_a(2);
end

figure()
% Iterative kmeans
for num_cluster = 4:9
    disp(num_cluster)
    % Main kmeans algorithms
    [cluster_idx, cluster_center] = ...
        kmeans(X, num_cluster, 'distance', 'sqEuclidean', ...
                               'emptyaction', 'singleton', ...
                               'Replicates', 5);
    pixel_labels = reshape(cluster_idx, nrows, ncols);
    [~, ind] = min(abs(cluster_center(:,1) - red));
    bw = (pixel_labels == ind);
    
    % Clean up the black white image
    bw = bw_clean(bw);
    
    % Check barrel in the black white image
    load barrel_model
    [bw_barrel, rp_barrel] = predict_barrel(bw, barrel_model);
    
    % Visualize
    subplot(2,2,1); imshow(im);
    subplot(2,2,2); imshow(pixel_labels, []);
    subplot(2,2,3); imshow(bw);
    subplot(2,2,4); imshow(bw_barrel);
    drawnow
    % Check if a barrel is detected
    if ~isempty(bw_barrel)
        break
    end
        
end

end