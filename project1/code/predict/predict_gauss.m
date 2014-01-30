function P = predict_gauss(X, mu, sigma)

N = size(X,1);
P = zeros(N,1);
for i = 1:N
    x_minus_mu = X(i,:) - mu;
    P(i) = 1 / sqrt((2*pi)^2*det(sigma)) * exp(-1/2*x_minus_mu*inv(sigma)*x_minus_mu');
end

end