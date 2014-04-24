% example to visualize the data
load ../data/log.mat
%%

% select the robot ID to visualize
robotID = 2;

for i = 1:15:numel(robot{robotID}.packet)

    % read the current packet and extract info
    curPacket = robot{robotID}.packet{i};
    location = [curPacket.pose.x, curPacket.pose.y];
    yaw = curPacket.pose.yaw;
    hLidar = curPacket.hlidar;
    vLidar = curPacket.vlidar;

    % visualizing...
    figure(1), hold on;

    % obstacle from horizontal lidar
    pts = find(hLidar.cs > 0);
    plot(hLidar.xs(pts), hLidar.ys(pts), '.', 'MarkerSize', 0.5, 'color',[1,0,0]);

    % non-obstacle from horizontal lidar
    pts = find(hLidar.cs < 0);
    plot(hLidar.xs(pts), hLidar.ys(pts), '.', 'MarkerSize', 0.5, 'color',[0,1,0]);

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
    title(sprintf('Packet # %d', i));
    axis([-10,80,-35,15]);
    pause(0.025);

end
