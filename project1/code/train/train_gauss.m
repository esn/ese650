function [ gauss ] = train_gauss( X )

N = size(X,1);
gauss.mu = mean(X,1);
x_minus_mu = bsxfun(@minus, X, gauss.mu);
gauss.sigma = x_minus_mu' * x_minus_mu / N;

end