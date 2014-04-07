function [ F ] = gmm_feature( im )
%GMM_FEATURE 
load('mat/gmm.mat')

F = [];

for i = 1:numel(gmm)
    f = gmm(i).test(im);
    F = [F f];
end

end
