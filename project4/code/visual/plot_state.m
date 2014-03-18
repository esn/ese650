function plot_state( h_fig, time, state, name, type, view, line_width )
%PLOT_STATE visualize state data

if nargin < 7, line_width = 2; end
if nargin < 6, view = 'sep'; end
if nargin < 5, type = 'vic'; end
if nargin < 4, name = 'pos'; end
if isempty(h_fig), h_fig = figure(); end

line_colors = lines(5);

switch type
    case 'vic'
        line_color = line_colors(3,:);  % red
    case 'des'
        line_color = line_colors(1,:);  % blue
    case 'est'
        line_color = line_colors(2,:);  % dark green
    case 'mea'
        line_color = line_colors(4,:);  % pale blue
    otherwise
        line_color = line_colors(5,:);  % purple
end

switch name
    case 'pos'
        labels = {'x [m]', 'y [m]', 'z [m]'};
    case 'vel'
        labels = {'xdot [m/s]', 'ydot [m/s]', 'zdot [m/s]'};
    case 'eul'
        labels = {'roll [rad]', 'pitch [rad]', 'yaw [rad]'};
    case 'omg'
        labels = {'rdot [rad/s]', 'pdot [rad/s]', 'yawdot [rad/s]'};
    case 'acc'
        labels = {'xddot [m/s^2]', 'yddot [m/s^2]', 'zddot [m/s^2]'};
end

figure(h_fig)
if strcmp(view, 'sep')
    % Plot seperate
    for i = 1:3
        subplot(3, 1, i)
        hold on
        plot(time, state(i,:), 'Color', line_color, ...
            'LineWidth', line_width);
        hold off
        if numel(time) ~= 1 || (time(1) - time(end)) < sqrt(eps)
            xlim([time(1), time(end)])
        end
        xlabel('time [s]')
        ylabel(labels{i})
        grid on
        axis tight
        set(gca, 'Box', 'On')
    end
elseif strcmp(view, '3d')
    % Plot 3d
    hold on
    plot3(state(1,:), state(2,:), state(3,:), ...
        'Color', line_color, 'LineWidth', line_width)
    hold off
    grid on
    xlabel(labels{1});
    ylabel(labels{2});
    zlabel(labels{3});
end

end
