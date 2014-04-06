clear all;
close all;

%% Load data
mat_name = 'data.mat';
load(mat_name);

%% Instantiate MDP
% for i = 1:3
% mdp(i) = MDP(sub(i).im);
% mdp(i).addDrivePolicy();
% % mdp.addWalkPolicy();
% mdp(i).plot();
% end
load('mdp.mat')
%% Instantiate LEARCH
learch = LEARCH(mdp(1:2), mdp(3));