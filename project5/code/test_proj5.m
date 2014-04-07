clear all;
close all;

%% Load data
mat_name = 'mat/data.mat';
load(mat_name);

%% Instantiate MDP for diver
n = 2:3:numel(sub);
for i = 1:numel(n)
    mdp(i) = MDP(sub{n(i)}, 'walk');
    mdp(i).addPolicy();
    mdp(i).genLossField();
    mdp(i).plot();
end
save('mat/mdp', 'mdp')
load('mat/mdp')

%% Instantiate LEARCH
T = 20;
learch = LEARCH(mdp(1:4), mdp(5:6), T);
learch.train(true);
learch.test();