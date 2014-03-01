function [ ind ] = quantization( data, min_data, max_data, nbins )
%QUANTIZATION vector quantization for input data

data = bsxfun(@max, data, min_data);
data = bsxfun(@min ,data, max_data);

bin_ranges = zeros(nbins+1, 3);
for i = 1:3
    bin_ranges(:,i) = linspace(min_data(i), max_data(i), nbins+1)';
end

subs = zeros(size(data));
for i = 1:3
    [~, sub] = histc(data(:,i), bin_ranges(:,i));
    subs(:,i) = sub;
end
subs(subs > nbins) = nbins;
ind = sub2ind(nbins*ones(1,3), subs(:,1), subs(:,2), subs(:,3));
ind = ind';
end

