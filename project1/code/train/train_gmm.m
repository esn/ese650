function [ model ] = train_gmm(data, id, cspace)
% TRAIN_GMM
if nargin < 3, cspace = 'lab'; end
if nargin < 2 || isempty(id), id = 1:length(data); end
s = 20;

X = [];

for i = 1:length(id)
    j = id(i);
    data_j = data(j);
    if strcmp(cspace, 'rgb')
        im = double(data_j.rgb);
        nrows = size(im, 1);
        ncols = size(im, 2);
        x = reshape(im, nrows*ncols, 3);
    elseif strcmp(cspace, 'lab')
        im =  double(data_j.lab);
        nrows = size(im, 1);
        ncols = size(im, 2);
        x = reshape(im, nrows*ncols, 3);
    end
    X = [X;x(data_j.bw,:)];
end
X = X(1:s:end, :);

options = statset('Display', 'final');
model = gmdistribution.fit(X, 2, 'Replicates', 3, 'SharedCov', false, 'Options', options);

end