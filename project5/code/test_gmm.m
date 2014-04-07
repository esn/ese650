clear all
close all

%% Load image
load('data.mat')

gmm_green = GMM(3, 'green', 'lab');
gmm_green.train(sub(1:5:numel(sub)));
gmm_green.test(sub(2:4:10));