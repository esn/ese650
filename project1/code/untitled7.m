% load bw
% 
% cc = bwconncomp(bw);
% rp = regionprops(cc);
% 
% for i = 1:length(rp)
%     area = rp(i).Area;
%     bb = rp(i).BoundingBox;
%     aratio = bb(4)/bb(3);
%     fill = area/(bb(3)*bb(4));
%     X(i,:) = [aratio fill];
% end
% 
% load barrel_model
% X = [1.5 0.9; 1.3 0.6];
% 
% P = predict_gauss(X, barrel_model.mu, barrel_model.sigma);

load valid
iter_kmeans_lab(valid(1));