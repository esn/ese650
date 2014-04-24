clearvars -except robot
close all
clc

if ~exist('robot', 'var')
    load('../data/log.mat')
    disp('Load log.mat')
else
    disp('log.mat in workspace')
end