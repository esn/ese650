function [ F ] = gmm_feature( im )
%GMM_FEATURE 
load('gmm.mat')

F = [];

for i = 1:numel(gmm)
    f = gmm.test(im);
    F = [F f];
end

end

