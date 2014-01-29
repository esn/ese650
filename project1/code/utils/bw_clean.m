function [ bw ] = bw_clean( bw, area_thresh )

if nargin < 2, area_thresh = 150; end
% remove anything with area less than a certain threshold
bw = bwareaopen(bw, area_thresh); 
bw = imclearborder(bw);
% fill in all the holes in bw
% sed = strel('Diamond', 1);
% bw = imerode(bw, sed);
bw = imfill(bw, 'holes');

end