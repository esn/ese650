function plot_colorspace(data, id, s)
% PLOT_COLORSPACE 
if nargin < 3, s = 50; end
if nargin < 2 || isempty(id), id = 1:length(data); end
figure(1)
cspace_label = {'RGB', 'YCbCr', 'Lab', 'HSV'};
xlabels = {'R', 'Y', 'L', 'H'};
ylabels = {'G', 'Cb', 'a', 'S'};
zlabels = {'B', 'Cr', 'b', 'V'};
for i = 1:length(cspace_label)
    h(i) = subplot(2,2,i);
    title(cspace_label{i})
    xlabel(xlabels{i})
    ylabel(ylabels{i})
    zlabel(zlabels{i})
    hold on
    axis equal
    grid on
    view(3)
end

%% Plotting
for i = 1:length(id)
    j = id(i);
    data_j = data(j);
    
    % Generate different colorspace
    im_rgb = data_j.rgb;
    im_ycbcr = rgb2ycbcr(im_rgb);
    im_lab = data_j.lab;
    im_hsv = rgb2hsv(im_rgb);
    im_bw = data_j.bw;
    im_cspace = {im_rgb, im_ycbcr, im_lab, im_hsv};
    
    % Extract barrel and non-barrel pixels
    im_in  = cell(1,4);
    im_out = cell(1,4);
    for k = 1:length(im_cspace)
        im_in{k} = zeros(sum(im_bw(:)), 3);
        im_out{k} = zeros(size(im_rgb, 1) * size(im_rgb, 2) - sum(im_bw(:)), 3);
        for c = 1:3
            channel = im_cspace{k}(:,:,c);
            im_in{k}(:,c) = channel(im_bw);
            im_out{k}(:,c) = channel(~im_bw);
            if k == 1
                ave_rgb_in(c) = mean(im_in{k}(:,c));
                ave_rgb_out(c) = mean(im_out{k}(:,c));
            end
        end
    end
    
    % Plot
    for k = 1:length(im_cspace)
        plot3(h(k), im_in{k}(1:s:end,1), im_in{k}(1:s:end,2), im_in{k}(1:s:end,3), ...
            '+', 'MarkerSize', 2, 'Color', ave_rgb_in/255)
        plot3(h(k), im_out{k}(1:s:end,1), im_out{k}(1:s:end,2), im_out{k}(1:s:end,3), ...
            '.', 'MarkerSize', 2, 'Color', ave_rgb_out/255)
    end
end

end