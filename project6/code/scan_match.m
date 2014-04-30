%%%
%> @brief icp scan matching algorithm
%> Matches scan s2 to scan s1, so that s1 = rt * s2
%>
%> @param pn1 reference pose node where the 1st scan was taken
%> @param pn2 template pose node where the 2nd scan was taken
%> @param res resolution of the grid map
%> @param vis visualization flag
%>
%> @return rt    rototranslation matrix so that s1 = rt * s2
%> @return infm  information matrix related to this match
%> @return valid flag indicates whether this match is an edge
%%%
function [rt, infm, valid] = scan_match(pn1, pn2, res, vis)
%SCAN_MATCH scan matching algorithm using libicp
%  [rt, cov, score] = scan_match(pn1, pn2, res)
if nargin < 4, vis = false; end
if nargin < 3, res = 0.2; end

% Assign variables
s1 = pn1.lscan;
s2 = pn2.lscan;
p1 = pn1.pose;
p2 = pn2.pose;

% Calculate pose difference in global frame
dyaw  = p2(3) - p1(3);
dxy_w = [p2(1) - p1(1); p2(2) - p1(2)];
R1tow = [cos(p1(3)) -sin(p1(3)); sin(p1(3)) cos(p1(3))];
% Transform displacement in world frame to reference frame
dxy_1 = R1tow'*dxy_w;
R2to1 = [cos(dyaw) -sin(dyaw); sin(dyaw) cos(dyaw)];
% tr_guess is just the rototranslation matrix from 2 to 1
rt_guess = [R2to1 dxy_1; 0 0 1];

% Use libicp to do scan matching
rt = icpMex(s1, s2, rt_guess, 1, 'point_to_point');
s2_fit = bsxfun(@plus, rt(1:2,1:2)*s2, rt(1:2,3));

% Evaluate correlation using map_correlation
% Create an empty map
xmin = min([s1(1,:), s2_fit(1,:)]);
xmax = max([s1(1,:), s2_fit(1,:)]);
ymin = min([s1(2,:), s2_fit(2,:)]);
ymax = max([s1(2,:), s2_fit(2,:)]);
sizex = ceil((xmax - xmin) / res + 1);
sizey = ceil((ymax - ymin) / res + 1);
map = zeros(sizex, sizey, 'int8');
% Convert from meters to cells
xis = round((s1(1,:) - xmin) ./ res);
yis = round((s1(2,:) - ymin) ./ res);
indGood = (xis > 1) & (yis > 1) & (xis < sizex) & (yis < sizey);
inds = sub2ind(size(map), xis(indGood), yis(indGood));
map(inds) = 2;

% sigma = sqrt(2);
% G = fspecial('gaussian', ceil(sigma), sigma/2);
% map = imfilter(map, G);

% Calculate map_correlation
x_im = xmin:res:xmax;
y_im = ymin:res:ymax;
x_range = (-1:1) * res;
y_range = (-1:1) * res;
c = map_correlation(map, x_im, y_im, ...
    [s2_fit; zeros(1,length(s2_fit))], ...
    x_range, y_range);
score = c(1)/(length(s1) + length(s2))*2;

% Calcualte covariance
if score < 0.85
    % If score is not good, just use rt_guess and a fixed covariance
    valid = false;
    rt = rt_guess;
    infm = diag([20 20 100]);
else
    % If score is good, then use rt and calculate covariance
    valid = true;
    infm = diag([20 20 100]);
end

%%
if vis
    % Visualization
    l = 1;
    subplot(2,2,1)
    title('global')
    hold on
    plot(pn1.gscan(1,:), pn1.gscan(2,:), 'b.')
    plot(p1(1), p1(2), 'bo')
    plot(p1(1) + [0 l*cos(p1(3))], ...
        p1(2) + [0 l*sin(p1(3))], 'b')
    plot(pn2.gscan(1,:), pn2.gscan(2,:), 'r.')
    plot(p2(1), p2(2), 'ro')
    plot(p2(1) + [0 l*cos(p2(3))], ...
        p2(2) + [0 l*sin(p2(3))], 'r')
    beautify(gcf)
    
    subplot(2,2,2)
    title('local')
    hold on
    % Scans in their own frames
    plot(s1(1,:), s1(2,:), 'b.');
    plot(s2(1,:), s2(2,:), 'g.');
    % Pose1 in reference frame
    plot(0, 0, 'bo')
    plot([0 l], [0 0], 'b')
    % Pose 2 in reference frame
    
    plot(dxy_1(1), dxy_1(2), 'ro')
    plot(dxy_1(1) + [0 l*cos(dyaw)], ...
        dxy_1(2) + [0 l*sin(dyaw)], 'r')
    plot(s2_fit(1,:), s2_fit(2,:), 'r.')
    beautify(gcf)
    
    % Plot
    subplot(2,2,3)
    imagesc(map)
    colormap(gray)
    hold on
    plot((s2_fit(2,:)-ymin)/res, (s2_fit(1,:)-xmin)/res, 'r.')
    axis ij
    title('map')
    
    subplot(2,2,4)
    surf(c)
    title(num2str(score))
end

end
