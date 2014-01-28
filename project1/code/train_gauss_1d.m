function model = train_gauss_1d(X)
% TRAIN_ARATIO
model.mu = mean(X);
model.sigma = 1/length(X) * sum((X - model.mu).^2);
end