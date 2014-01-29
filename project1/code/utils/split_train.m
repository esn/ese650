function [ train, valid ] = split_train( train_path, train_percentage )
%SPLIT_TRAIN Split training images to 80% train set and 20% validation set

if nargin < 2, train_percentage = 0.8; end
if nargin < 1, train_path = './train/'; end

dirstruct = dir([train_path '/*.png']);
cform = makecform('srgb2lab');

% Get all distances
all_dist = zeros(1, length(dirstruct));
for i = 1:length(dirstruct)
    all_dist(i) = get_dist_from_fname(dirstruct(i).name);
end

% Get all distinct distances
distinct_dist = unique(all_dist);

% Split images to train and valid set
i_train = 0;
i_valid = 0;
base_index = 0;

for i = 1:length(distinct_dist)
    fprintf('Processing distance %d...\n', distinct_dist(i))
    num_same_dist = sum(all_dist == distinct_dist(i));
    num_train = round(train_percentage * num_same_dist);
    perm = randperm(num_same_dist);
    
    for j = 1:num_same_dist
        k = base_index + perm(j); % Get index
        im = imread([train_path dirstruct(k).name]);
        im = im_downsample(im, 5); % Downsample image
        lab = applycform(im, cform);
        if j <= num_train
            i_train = i_train + 1;
            train(i_train).name = dirstruct(k).name;
            train(i_train).im = im;
            train(i_train).lab = lab;
            train(i_train).d = all_dist(k);
        else
            i_valid = i_valid + 1;
            valid(i_valid).name = dirstruct(k).name;
            valid(i_valid).im = im;
            valid(i_valid).lab = lab;
            valid(i_valid).d = all_dist(k);
        end
    end
   
    base_index = base_index + num_same_dist;
end

end