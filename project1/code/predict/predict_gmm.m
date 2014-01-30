function [ P ] = predict_gmm( X, model )

P = zeros(size(X,1), model.NComponents);
for i = 1:model.NComponents
    Sigma = model.Sigma(:,:,i);
    mu = model.mu(i,:);
    for j = 1:length(X)
        x_minus_mu = X(j,:) - mu;
        P_x_given_z(j,i) = 1/sqrt((2*pi)^2*det(Sigma))*exp(-1/2*x_minus_mu*inv(Sigma)*x_minus_mu');
    end
end
P = sum(bsxfun(@times, P_x_given_z, model.PComponents), 2);
end

