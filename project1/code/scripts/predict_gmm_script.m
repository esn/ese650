data = train;
id = 1:40;
load gm_lab
load gm_rgb
for i = 1:length(id)
    data_j = data(id(i));
    P_rgb = predict_gmm_rgb(data_j, gm_rgb);
    P_rgb = normalize(P_rgb);
    figure(1)
    subplot(2,2,1)
    imshow(data_j.im);
    subplot(2,2,2)
    imshow(P_rgb);
    subplot(2,2,3)
    bw = P_rgb > 0.075;
    imshow(bw);
    subplot(2,2,4)
    bw = bw_clean(bw);
    imshow(bw);
    drawnow
end