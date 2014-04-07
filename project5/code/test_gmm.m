clear all
close all

%% Load image
load('data.mat')

gmm_green = GMM(2, 'green', 'ycbcr');
gmm_green.train(sub(1:4:numel(sub)), 'ycbcr');

gmm_green.test(sub(2:4:10));