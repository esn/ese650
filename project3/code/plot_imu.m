function [ h_fig ] = plot_imu( h_fig, imu, t, type, color )
% PLOT_IMU plot imu data assuming the order acc, omg
% [ h_fig ] = plot_imu( h_fig, imu, t, type, color )

plot_time = true;
if isempty(t), plot_time = false; end
if isempty(h_fig), h_fig = figure(); end

% Plot imu data
if strcmp(type, 'acc')
    labels = {'ax', 'ay', 'az'};
    data = imu(:,1:3);
elseif strcmp(type, 'omg')
    labels = {'wx', 'wy', 'wz'};
    data = imu(:,4:6);
elseif strcmp(type, 'all')
    labels = {'ax', 'ay', 'az', 'wx', 'wy', 'wz'};
    data = imu;
end
num_plot = size(data,2)/3;
figure(h_fig);
for i = 1:num_plot
    for j = 1:3
        subplot(3, num_plot, num_plot*(j-1)+i)
        hold on
        if plot_time
            plot(t - t(1), data(:,j), 'Color', color, 'LineWidth', 1)
        else
            plot(data(:,j), 'Color', color, 'LineWidth', 1)
        end
        hold off
        title(labels{j})
        axis tight
    end
end

end
