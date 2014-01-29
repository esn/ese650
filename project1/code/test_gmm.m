% Test gmm
data = train;
id = 1:40;

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

X_red = X_red(1:10:end,:);
X_nred = X_nred(1:10:end,:);

options = statset('Display', 'final');
gm_red = gmdistribution.fit(X_red, 2, 'Replicates', 3, 'SharedCov', false, 'Options', options);

gm_nred = gmdistribution.fit(X_nred, 5, 'Replicates', 3, 'SharedCov', false, 'Options', options);