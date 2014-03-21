function [ hout ] = plot_cart( hin, s, step )

if nargin < 3, step = 1; end
x = s(1,1:step:end);
y = s(2,1:step:end);
theta = s(3,1:step:end);
% w = 0.3937;
l = 0.5842;
% vert = [l w; -l w; -l -w; l -w]/2;
% vert_rot_x = bsxfun(@times, vert(:,1), cos(theta)) - bsxfun(@times, vert(:,2), sin(theta));
% vert_rot_y = bsxfun(@times, vert(:,1), sin(theta)) + bsxfun(@times, vert(:,2), cos(theta));
% x_vert = bsxfun(@plus, x, vert_rot_x);
% y_vert = bsxfun(@plus, y, vert_rot_y);

if isempty(hin)
    %     h(1) = patch(x_vert, y_vert, 'k', 'FaceAlpha', 0);
    hold on
    hin(1) = plot(x, y, 'o');
    hin(2) = quiver(x, y, l.*cos(theta), l.*sin(theta));
    hold off
    axis equal
else
    set(hin(1), 'XData', x, 'YData', y);
    set(hin(2), 'XData', x, 'YData', y, ...
        'UData', l.*cos(theta), 'VData', l.*sin(theta))
end

hout = hin;

end

