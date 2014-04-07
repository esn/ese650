clear all
close all

%% Load image
load('data.mat')
features   = {'green', 'side_red', 'side_white', 'road', 'roof_dark', 'roof_bright'};
n_clusters = [      3,          2,            2,      3,           2,             2];
cspace = 'hsv';

for i = 1:numel(features)
    gmm(i) = GMM(n_clusters(i), features{i}, cspace);
    gmm(i).train(sub(1:5:numel(sub)));
    gmm(i).test(sub(2:5:numel(sub)), true);
end
save('gmm', 'gmm')