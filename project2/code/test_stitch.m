clear all; close all; clc;

data_id = 9;

load(sprintf('../vicon/viconRot%d.mat', data_id));
rot_vic = rots;
t_vic   = ts;
load(sprintf('../cam/cam%d.mat', data_id));
t_cam   = ts;

%%
if 0
    figure()
    for i = 190:20:length(t_cam)
        if i == 190
            h_cam = imagesc(cam(:,:,:,i));
            axis image
        else
            set(h_cam, 'CData', cam(:,:,:,i));
            t_cam_i = t_cam(i);
            vic_i   = find((t_vic - t_cam_i) > 0, 1, 'first');
            rot_vic_i = rot_vic(:,:,vic_i);
            imwrite(cam(:,:,:,i), sprintf('image%d.png', i), 'png');
        end
        drawnow
    end
end

%%
f = 300;
[nr, nc, ~, ~] = size(cam);
nr_canvas = 400;
nc_canvas = ceil(2*pi*f)+2;
x_c_hat = nc_canvas/2;
y_c_hat = nr_canvas/2;
canvas = zeros(nr_canvas, nc_canvas, 3, 'uint8');

for i = 190:5:length(cam) - 200
    img = cam(:,:,:,i);
    vic_i = find(t_vic > t_cam(i), 1, 'first');
    wrb = rot_vic(:,:,vic_i);
    [x_img, y_img] = meshgrid(1:nc, 1:nr);
    x_img = x_img(:); y_img = y_img(:); z_img = ones(size(y_img)) * f;
    P_b = bsxfun(@plus, [z_img'; -x_img'; -y_img'], [0; nc/2; nr/2]);
    P_w = wrb * P_b;
    theta = atan2(P_w(2,:), P_w(1,:));
    h       = bsxfun(@rdivide, P_w(3,:), sqrt(P_w(1,:).^2 + P_w(2,:).^2));
    x_hat   = round(-f * theta + x_c_hat);
    y_hat   = round(-f * h + y_c_hat);
    
    for k = 1:length(x_hat)
        if y_hat(k) < nr_canvas - 1 && y_hat(k) > 1
            canvas(y_hat(k), x_hat(k), :) = img(y_img(k), x_img(k), :);
        end
    end
    imshow(canvas)
    drawnow
end