function plot_colorspace_2d(data, id, s)
% PLOT_COLORSPACE 
if nargin < 3, s = 50; end
if nargin < 2, id = 1:length(data); end
figure(1)
cspace_label = {'YCbCr', 'Lab'};
xlabels = {'Y', 'L'};
ylabels = {'Cb', 'a'};
zlabels = {'Cr', 'b'};
for i = 1:length(cspace_label)
    h(i) = subplot(1,2,i);
    title(cspace_label{i})
    xlabel(ylabels{i})
    ylabel(zlabels{i})
    hold on
    axis equal
    grid on
end

%% Plotting
for i = 1:length(id)
    j = id(i);
    data_j = data(j);
    
    % Generate different colorspace
    im_rgb = data_j.im;
    im_ycbcr = rgb2ycbcr(im_rgb);
    im_lab = data_j.lab;
    im_bw = data_j.bw;
    im_cspace = {im_ycbcr, im_lab};
    
    % Extract barrel and non-barrel pixels
    im_in  = cell(1,2);
    im_out = cell(1,2);
    for k = 1:length(im_cspace)
        im_in{k} = zeros(sum(im_bw(:)), 3);
        im_out{k} = zeros(size(im_rgb, 1) * size(im_rgb, 2) - sum(im_bw(:)), 3);
        for c = 1:3
            channel = im_cspace{k}(:,:,c);
            im_in{k}(:,c) = channel(im_bw);
            im_out{k}(:,c) = channel(~im_bw);
            if k == 1
                channel = im_rgb(:,:,c);
                ave_rgb_in(c) = mean(channel(im_bw));
                ave_rgb_out(c) = mean(channel(~im_bw));
            end
        end
    end
    
    % Plot
    for k = 1:length(im_cspace)
        plot(h(k), im_in{k}(1:s:end,2), im_in{k}(1:s:end,3), ...
            '+', 'MarkerSize', 2, 'Color', ave_rgb_in/255)
        plot(h(k), im_out{k}(1:s:end,2), im_out{k}(1:s:end,3), ...
            '.', 'MarkerSize', 2, 'Color', ave_rgb_out/255)
    end
end
change_font(gcf, 12)
end