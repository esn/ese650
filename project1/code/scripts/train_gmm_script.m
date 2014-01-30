init_dataset
% train a model on lab color space
gm_lab = train_gmm(train, [], 'lab');
save('gm_lab.mat', 'gm_lab');
% train another model on rgb color space
gm_rgb = train_gmm(train, [], 'rgb');
save('gm_rgb.mat', 'gm_rgb');