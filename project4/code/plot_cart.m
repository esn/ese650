function [ hout ] = plot_cart( s, step )

w = 0.3937;
l = 0.5842;
x = s(1,1:step:end);
y = s(2,1:step:end);
theta = s(3,1:step:end);
% vert = [l w; -l w; -l -w; l -w]/2;
% vert_rot_x = bsxfun(@times, vert(:,1), cos(theta)) - bsxfun(@times, vert(:,2), sin(theta));
% vert_rot_y = bsxfun(@times, vert(:,1), sin(theta)) + bsxfun(@times, vert(:,2), cos(theta));
% x_vert = bsxfun(@plus, x, vert_rot_x);
% y_vert = bsxfun(@plus, y, vert_rot_y);

persistent h
if isempty(h)
%     h(1) = patch(x_vert, y_vert, 'k', 'FaceAlpha', 0);
    h(1) = plot(x, y, 'o')
    hold on
    h(2) = quiver(x, y, l.*cos(theta), l.*sin(theta), 0);
    hold off
    axis equal
else
    set(h(1), 'XData', x_patch, 'YData', y_patch);
    set(h(2), 'XData', x, 'YData', y, ...
        'UData', l.*cos(theta), 'VData', l.*sin(theta))

hout = h;

end 

