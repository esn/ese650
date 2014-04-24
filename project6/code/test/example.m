% example to visualize the data
init_script
%%

% select the robot ID to visualize
num_robot = numel(robot);
for i_robot = 1:num_robot
for i_packet = 1:15:numel(robot{i_robot}.packet)

    % read the current packet and extract info
    curPacket = robot{i_robot}.packet{i_packet};
    location = [curPacket.pose.x, curPacket.pose.y];
    yaw = curPacket.pose.yaw;
    hLidar = curPacket.hlidar;
    vLidar = curPacket.vlidar;

    % visualizing...
    figure(1), hold on;

    % obstacle from horizontal lidar
    pts = find(hLidar.cs > 0);
    plot(hLidar.xs(pts), hLidar.ys(pts), '.', 'MarkerSize', 0.5, 'color','r');

    % non-obstacle from horizontal lidar
    pts = find(hLidar.cs < 0);
    plot(hLidar.xs(pts), hLidar.ys(pts), '.', 'MarkerSize', 0.5, 'color','g');

    % obstacle from vertical lidar
    pts = find(vLidar.cs > 0);
    plot(vLidar.xs(pts), vLidar.ys(pts), '.', 'MarkerSize', 0.5, 'color',[1,0,0]);

    % non-obstacle from vertical lidar
    pts = find(vLidar.cs < 0);
    plot(vLidar.xs(pts), vLidar.ys(pts), '.', 'MarkerSize', 0.5, 'color',[0,1,0]);

    % location with heading direction
    plot(location(1), location(2), 'ko', 'MarkerSize', 5);
    plot(location(1) + 5*cos(yaw), location(2) + 5*sin(yaw), 'k+', 'MarkerSize', 5);
    plot(location(1) + [0, 5*cos(yaw)], location(2) + [0,5*sin(yaw)], 'k-');

    %
    title(sprintf('Packet # %d', i_packet));
    axis([-10,80,-35,15]);
    pause(0.025);

end
end