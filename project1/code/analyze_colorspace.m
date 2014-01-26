%% Analysis on LAB and YCrCb
im = valid(1).im;
figure(1)
bw = roipoly(im);

%% Generate different colorspace
im_rgb = im;
im_ycbcr = rgb2ycbcr(im);
colorTransform = makecform('srgb2lab');
im_lab = applycform(im, colorTransform);
im_cspace = {im_ycbcr, im_lab};
cspace_label = {'YCbCr', 'Lab'};
xlabels = {'Y', 'L'};
ylabels = {'Cb', 'a'};
zlabels = {'Cr', 'b'};

%% Extract barrel and non-barrel pixels
im_in  = cell(1,2);
im_out = cell(1,2);
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
for i = 1:2
    subplot(1,2,i)
    hold on
    plot(im_in{i}(1:s:end,2), im_in{i}(1:s:end,3), 'r.')
    plot(im_out{i}(1:s:end,2), im_out{i}(1:s:end,3), 'b.')
    hold off
    axis equal
    grid on
    set(gca, 'Box', 'On')
    title(cspace_label{i})
    xlabel(ylabels{i})
    ylabel(zlabels{i})
end