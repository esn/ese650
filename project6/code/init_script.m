clearvars -except robot
close all
clc

%% Addpath
addpath(genpath('.'));
addpath(genpath('../3rdparty'));

%% Load project dataset
if ~exist('robot', 'var')
    load('../data/log.mat')
    disp('Load log.mat')
else
    disp('log.mat in workspace')
end