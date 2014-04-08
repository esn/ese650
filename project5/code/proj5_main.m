clear all;
close all;

%% Load data
mat_name = 'mat/data.mat';
rgb_name = 'mat/rgb.mat';
load(mat_name);
load(rgb_name);
type = 'walk';

%% Instantiate MDP for diver
n = 1:2:numel(sub);
for i = 1:numel(n)
    mdp(i) = MDP(sub{n(i)}, type);
    mdp(i).addPolicy();
    mdp(i).plot();
end
mdp(i+1) = MDP(im_rgb(500:1500,1000:2500,:), type);
mdp(i+1).addPolicy();
% save(['mat/mdp_' type], 'mdp')
%%
clear mdp
load(['mat/mdp_' type])

%% Instantiate LEARCH
T = 25;
m = floor(0.6*numel(mdp));
learch = LEARCH(mdp(1:m-1), mdp(m:end-1), T);
learch.train(true);
% save(['mat/learch_' type], 'learch')

%%
load(['mat/learch_', type]);

learch.test(mdp(end));
learch.test();

%%
mdp(end).removePolicy();
mdp(end).addPolicy();
learch.test(mdp(end));