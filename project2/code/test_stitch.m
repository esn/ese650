clear all; close all; clc;

data_id = 8;

load(sprintf('../vicon/viconRot%d.mat', data_id));
rot_vic = rots;
t_vic   = ts;
load(sprintf('../cam/cam%d.mat', data_id));
t_cam = ts;

%%

figure()
for i = 190:length(t_cam)
    if i == 190
        h_cam = imagesc(cam(:,:,:,i));
        axis image
    else
        set(h_cam, 'CData', cam(:,:,:,i));
        t_cam_i = t_cam(i);
        vic_i   = find((t_vic - t_cam_i) > 0, 1, 'first');
        rot_vic_i = rot_vic(:,:,vic_i);
        
    end
    drawnow
end