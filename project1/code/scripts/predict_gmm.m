init_dataset
load gm
data = train;
id = 40;

im = data(id).im;
im_lab = data(id).lab;
ab = double(im_lab(:,:,2:3));
nrows = size(ab, 1);
ncols = size(ab, 2);
X = reshape(ab, nrows*ncols, 2);

P_red = gm.P_red;
P_nred = 1 - gm.P_red;

for i = 1:gm.red.NComponents
    Sigma = gm.red.Sigma(:,:,i);
    mu = gm.red.mu(i,:);
    for j = 1:length(X)
        x_minus_mu = X(j,:) - mu;
        P_x_given_z(j,i) = 1/sqrt((2*pi)^2*det(Sigma))*exp(-1/2*x_minus_mu*inv(Sigma)*x_minus_mu');
    end
end

P_x_given_red = sum(bsxfun(@times, P_x_given_z, gm.red.PComponents), 2);

for i = 1:gm.nred.NComponents
    Sigma = gm.nred.Sigma(:,:,i);
    mu = gm.nred.mu(i,:);
    for j = 1:length(X)
        x_minus_mu = X(j,:) - mu;
        P_x_given_z(j,i) = 1/sqrt((2*pi)^2*det(Sigma))*exp(-1/2*x_minus_mu*inv(Sigma)*x_minus_mu');
    end
end

P_x_given_nred = sum(bsxfun(@times, P_x_given_z, gm.nred.PComponents), 2);

P_x = P_x_given_red * P_red + P_x_given_nred * P_nred;

P_red_given_x = P_x_given_red * P_red ./ P_x;
P_nred_given_x = P_x_given_nred * P_nred ./ P_x;
bw = P_red_given_x > P_nred_given_x;
bw = reshape(bw, nrows, ncols);
bw = bwareaopen(bw, 150);
figure(1)
subplot(1,2,1)
imshow(im)
subplot(1,2,2)
imshow(bw)