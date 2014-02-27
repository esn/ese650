function h_fig = PlotImuData( imu, gesture, varargin )
% PLOTIMUDATA visualize imu data
plot_list = varargin;
if nargin < 3, plot_list = {'acc', 'omg'}; end
if nargin < 2, gesture = 'unknown'; end

% Split imu data
[t, acc, omg, mag] = SplitImuData( imu );

% Plot imu data
h_fig = figure('Name', gesture);
num_plot = length(plot_list);
for i = 1:num_plot
    if strcmp(plot_list{i}, 'acc')
        data = acc;
        labels = {'ax', 'ay', 'az'};
    elseif strcmp(plot_list{i}, 'omg')
        data = omg;
        labels = {'wx', 'wy', 'wz'};
    elseif strcmp(plot_list{i}, 'mag')
        data = mag;
        labels = {'mx', 'my', 'mz'};
    end
    for j = 1:3
        subplot(3, num_plot, num_plot*(j-1)+i)
        plot(t, data(:,j))
        title(labels{j})
        xlim([t(1), t(end)])
    end
end

end
