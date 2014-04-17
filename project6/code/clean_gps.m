clear all
close all
clc

%%
load ../data/LOG.mat

num_robot = numel(robot);
for i_robot = 1:num_robot
    num_packet = numel(robot{i_robot}.packet);
    for i_packet = 1:num_packet
        robot{i_robot}.packet{i_packet}.pose = ...
            rmfield(robot{i_robot}.packet{i_packet}.pose, 'gps');
    end
end

save('robot.mat', 'robot')