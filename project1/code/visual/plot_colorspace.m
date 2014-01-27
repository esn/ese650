%% Analyse colorspace
im = valid(1).im;
figure(1)
bw = roipoly(im);

%% Generate different colorspace
im_rgb = im;
im_ycbcr = rgb2ycbcr(im);
colorTransform = makecform('srgb2lab');
im_lab = applycform(im, colorTransform);
im_hsv = rgb2hsv(im);
im_cspace = {im_rgb, im_ycbcr, im_lab, im_hsv};
cspace_label = {'RGB', 'YCbCr', 'Lab', 'HSV'};
xlabels = {'R', 'Y', 'L', 'H'};
ylabels = {'G', 'Cb', 'a', 'S'};
zlabels = {'B', 'Cr', 'b', 'V'};

%% Extract barrel and non-barrel pixels
im_in  = cell(1,4);
im_out = cell(1,4);
for i = 1:length(im_cspace)
    im_in{i} = zeros(sum(bw(:)), 3);
    im_out{i} = zeros(size(im,1)*size(im,2)-sum(bw(:)), 3);
    for c = 1:3
        channel = im_cspace{i}(:,:,c);
        im_in{i}(:,c) = channel(bw);
        im_out{i}(:,c) = channel(~bw);
    end
end

%% Visualize colorspace
s = 80;
figure(2)
for i = 1:4
    subplot(2,2,i)
    view(3)
    hold on
    scatter3(im_in{i}(1:s:end,1), im_in{i}(1:s:end,2), im_in{i}(1:s:end,3), 1, 'r')
    scatter3(im_out{i}(1:s:end,1), im_out{i}(1:s:end,2), im_out{i}(1:s:end,3), 1, 'b')
    hold off
    axis equal
    grid on
    title(cspace_label{i})
    xlabel(xlabels{i})
    ylabel(ylabels{i})
    zlabel(zlabels{i})
end