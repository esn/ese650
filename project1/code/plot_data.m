function plot_data(data, id)
%PLOT_DATA Plot data
if nargin < 2, id = 1:length(data); end

for i = 1:length(id)
    j = id(i);
    data_j = data(j);
    figure(1)
    
    subplot(2,2,1)
    imshow(data_j.im)
    title(sprintf('original image: %d, %s, distance: %d', ...
                  j, data_j.name, data_j.d));
    subplot(2,2,2)
    imshow(data_j.lab)
    title(sprintf('lab image: %d, %s, distance: %d', ...
                  j, data_j.name, data_j.d));
    subplot(2,2,3)
    imshow(data_j.bw)
    title(sprintf('barrel mask: %d, %s, distance: %d', ...
                  j, data_j.name, data_j.d));
    subplot(2,2,4)
    color_mask = repmat(data_j.bw, [1 1 3]);
    barrel = data_j.im;
    barrel(~color_mask) = 0;
    imshow(barrel)
    title(sprintf('barrel: %d, %s, distance: %d', ...
                  j, data_j.name, data_j.d));
    drawnow
    pause
end

end