fprintf('Kmeans failed. Starting GMM\n')
load gm_rgb
load barrel_model
test = train(4);
figure(1)
P_rgb = predict_gmm_rgb(test, gm_rgb);
bw = P_rgb > 0.07;
bw = bw_clean(bw, 50);
subplot(2,2,1)
imshow(test.im)
subplot(2,2,2)
imshow(bw)
subplot(2,2,3)
[bw_barrel, rp_barrel] = predict_barrel(bw, barrel_model, 0);
imshow(bw_barrel)
area = rp_barrel.Area;
c = rp_barrel.Centroid;
bb = rp_barrel.BoundingBox;
fill = area / (bb(3)* bb(4));

if fill < 0.7
    w = sqrt(area/1.5);
    h = w * 1.5;
    bw_barrel_shift = zeros(size(bw_barrel));
    bw_barrel_shift(round(c(2)-h/2):round(c(2)+h/2), round(c(1)-w/2):round(c(1)+w/2)) = 1;
    bw_barrel_shift = bw_barrel_shift & bw_barrel;
    subplot(2,2,4)
    imshow(bw_barrel_shift)
end

title('GMM Probability threshold')
drawnow