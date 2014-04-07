clear all;
close all;

%% Load data
mat_name = 'data.mat';
load(mat_name);

%% Instantiate MDP for diver
n = 5:10;
for i = 1:numel(n)
    mdp(i) = MDP(sub{n(i)}, 'walk');
    mdp(i).addPolicy();
    mdp(i).genLossField();
    mdp(i).plot();
end
save('mdp', 'mdp')
load('mdp')

%% Instantiate LEARCH
T = 20;
learch = LEARCH(mdp(1:3), mdp(4:5), T);
learch.train(true);
learch.test();