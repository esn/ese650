% Test gmm
data = train;
id = [1:4, 9:12, 13:16];
s = 20;
% Prepare for X_red and X_nred
X_red = [];
X_nred = [];
for i = 1:length(id)
    j = id(i);
    data_j = data(j);
    im_lab = data_j.lab;
    ab = double(im_lab(:,:,2:3));
    nrows = size(ab, 1);
    ncols = size(ab, 2);
    ab = reshape(ab, nrows*ncols, 2);
    X_red = [X_red; ab(data_j.bw,:)];
    X_nred = [X_nred; ab(~data_j.bw,:)];
end

X_red = X_red(1:s:end,:);
X_nred = X_nred(1:s:end,:);

options = statset('Display', 'final');
gm_red = gmdistribution.fit(X_red, 2, 'Replicates', 3, 'SharedCov', false, 'Options', options);
gm_nred = gmdistribution.fit(X_nred, 4, 'Replicates', 3, 'SharedCov', false, 'Options', options);
gm.red = gm_red;
gm.nred = gm_nred;
gm.P_red = length(X_red)/(length(X_red) + length(X_nred));
save('gm.mat','gm')