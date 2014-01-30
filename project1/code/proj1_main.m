init_dataset

dir_name = 'data/';
dirstruct = dir([dir_name '*.png']);
for i = 1:length(dirstruct)
    % Current test image
    im = imread([dir_name dirstruct(i).name]);
    dist = get_dist_from_fname(dirstruct(i).name);
    
    % Your algorithm here!
    [x, y, d] = myAlgorithm(im);
    
    % You may also want to plot and display other
    % diagnostic information such as the outlines
    % of connected regions, etc.
    d_hist(i) = d;
    dist_hist(i) = dist;
    hold off;
    pause;
end