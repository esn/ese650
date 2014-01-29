function [bw_barrel, rp_barrel] = predict_barrel( bw, barrel_model )

barrel_thresh = 2.3;

cc = bwconncomp(bw);
if cc.NumObjects == 0
    bw_barrel = [];
    rp_barrel = 0;
    return
end
rp = regionprops(cc, 'Area', 'BoundingBox', 'Centroid');

for i = 1:length(rp)
    area = rp(i).Area;
    bb = rp(i).BoundingBox;
    aratio = bb(4)/bb(3);
    fill = area/(bb(3)*bb(4));
    X(i,:) = [aratio fill];
end


P = predict_gauss(X, barrel_model.mu, barrel_model.sigma)
[val, ind] = max(P);

if val < barrel_thresh
    bw_barrel = [];
    rp_barrel = 0;
    return
end

rp_barrel = rp(ind);
bw_barrel = zeros(cc.ImageSize);
bw_barrel(cc.PixelIdxList{ind}) = 1;
    
end