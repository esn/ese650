clear all
close all

%% Load image
load('data.mat')
features   = ...
    {'green', 'side_red', 'side_white', 'road', 'roof_dark', 'roof_bright', };
n_clusters = ...
    [      4,          2,            2,      3,           2,             2];
cspace = 'hsv';

for i = 1:numel(features)
    gmm(i) = GMM(n_clusters(i), features{i}, cspace);
    gmm(i).train(sub(2:3:numel(sub)));
    p = gmm(i).test(sub(3:3:numel(sub)), true);
end
%% Save to mat
save('mat/gmm', 'gmm')