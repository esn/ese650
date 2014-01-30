function [bw, rp] = fix_barrel(bw, rp, fill_thresh)
if nargin < 3, fill_thresh = 0.7; end
area = rp.Area;
c = rp.Centroid;
bb = rp.BoundingBox;
fill = area / (bb(3)* bb(4));

if fill < fill_thresh
    disp('Barrel not good, fixing')
    w = sqrt(area/1.5);
    h = w * 1.5;
    bw_new = zeros(size(bw));
    bw_new(round(c(2)-h/2):round(c(2)+h/2), round(c(1)-w/2):round(c(1)+w/2)) = 1;
    bw_new = bw_new & bw;
    bw = bw_new;
end
bw = bwareaopen(bw, 20);
cc = bwconncomp(bw);
rp = regionprops(cc, 'Area', 'BoundingBox', 'Centroid', 'MajorAxisLength', 'MinorAxisLength');
end