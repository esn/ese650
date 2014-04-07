clear all;
close all;

%% Load data
mat_name = 'mat/data.mat';
load(mat_name);

%% Instantiate MDP for diver
n = 2:2:numel(sub);
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
m = floor(0.6*numel(n));
learch = LEARCH(mdp(1:m), mdp(m+1:end), T);
learch.train(true);
learch.test();