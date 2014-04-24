init_script
SAVE = true;

%% Plot raw SLAM results for each robot
figure(); hold on;

% extract position info
num_robot = numel(robot);
line_colors = lines(num_robot);
for i_robot = 1:numel(robot)
    num_packet = numel(robot{i_robot}.packet);
    pose = zeros(3, num_packet);
    for i_packet = 1:num_packet
        curr_packet = robot{i_robot}.packet{i_packet};
        pose(:,i_packet) = ...
            [curr_packet.pose.x, curr_packet.pose.y, curr_packet.pose.yaw];
    end
    % Plot
    plot(pose(1,:), pose(2,:), ...
        'Color', line_colors(i_robot,:), ...
        'LineWidth', 2)
end
hold off
% legend(mat2cell(num2str((1:num_robot)'), ones(1,length(1:num_robot))))
beautify(gcf);
title('Raw Robot Trajectories')
xlabel('x [m]')
ylabel('y [m]')
axis([-5 70 -30 15])
set(gcf, 'Position', [100 100 800 500])

%% Save figure to ./fig
if SAVE, savefig('fig/raw_traj'); end