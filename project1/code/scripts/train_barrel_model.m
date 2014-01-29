%% Train barrel model [aspect_ratio, fill_percentage]
load train
aratio = plot_aratio(train);
% ind = find(aratio < 2);
% aratio = aratio(ind);
fill = plot_fill(train);

X = [aratio(:), fill(:)];
barrel_model = train_gauss(X);
save('barrel_model.mat', 'barrel_model')