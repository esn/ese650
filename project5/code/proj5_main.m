clear all;
close all;

%% Load data
mat_name = 'mat/data.mat';
rgb_name = 'mat/rgb.mat';
load(mat_name);
load(rgb_name);

%% Instantiate MDP for diver
n = 1:2:numel(sub);
type = 'drive';
for i = 1:numel(n)
    mdp(i) = MDP(sub{n(i)}, type);
    mdp(i).addPolicy();
    mdp(i).plot();
end
mdp(i+1) = MDP(im_rgb(1000:2000,1000:2500,:), type);
mdp(i+1).addPolicy();
save(['mat/mdp_' type], 'mdp')
load(['mat/mdp_' type])

%% Instantiate LEARCH
T = 25;
m = floor(0.6*numel(mdp));
learch = LEARCH(mdp(1:m-1), mdp(m:end-1), T);
learch.train(true);
learch.test(mdp(end));
learch.test();
save(['mat/learch_' type], 'learch')