function [x, y, d] = myAlgorithm( im )

% Generate test structure
test.im = im_downsample(im, 4);
test.rgb = im2uint8(sqrt(im2double(test.im)));
cform = makecform('srgb2lab');
test.lab = applycform(test.im, cform);
load barrel_model
% Try kmeans
[bw_kmeans, rp_barrel] = predict_kmeans_lab(test);
% If kmeans fails
if isempty(rp_barrel)
    fprintf('Kmeans failed. Starting GMM\n')
    load gm_rgb 
    % Try gmm
    P_rgb = predict_gmm_rgb(test, gm_rgb);
    bw = P_rgb > 0.06;
    bw = bw_clean(bw, 100);
    [bw_barrel, rp_barrel] = predict_barrel(bw, barrel_model, 0);
    % If GMM fails
    if isempty(rp_barrel)
        % Use last results of kmeans
        fprintf('GMM failes. Use last result of kmeans')
        bw_barrel = bw_kmeans;
    else
        % Fix bw_barrel position
        [bw_barrel, ~] = fix_barrel(bw_barrel, rp_barrel);
    end
    subplot(2,2,3)
    imshow(bw)
    title('GMM Probability threshold')
    drawnow
else
    bw_barrel = bw_kmeans;
end


subplot(2,2,4)
imshow(bw_barrel)

% Get the most possible barrel
[bw_barrel, rp_barrel] = predict_barrel(bw_barrel, barrel_model, 0);
figure(2)
subplot(1,2,1)
imshow(test.im)
subplot(1,2,2)
imshow(bw_barrel)
hold on
plot(rp_barrel.Centroid(1), rp_barrel.Centroid(2), 'r+', 'MarkerSize', 8, 'LineWidth', 3)
rectangle('Position', rp_barrel.BoundingBox, 'EdgeColor', 'g', 'LineWidth', 2)
hold off
x = 0;
y = 0;
d = 0;

end