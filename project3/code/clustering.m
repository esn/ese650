function [ ind ] = clustering( data, centroids )
%CLUSTERING find the indices of the closest centroid
% [ ind ] = clustering( data, centroids )

ind = zeros(1,length(data));
for i = 1:length(data)
  d = sum(bsxfun(@minus, data(i,:), centroids).^2, 2);
  [~, ind(i)] = min(d);
end

end