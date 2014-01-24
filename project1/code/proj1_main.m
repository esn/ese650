init_dataset

dirstruct = dir('train/*.png');
for i = 1:length(dirstruct)
    
    % Current test image
    im = imread(['train/' dirstruct(i).name]);
    dist = get_distance(dirstruct(i).name);
    
    % Your algorithm here!
%     [x, y, d] = myAlgorithm(im);

    % Display results:
    hf = figure(1);
    image(im);
    hold on;
%     plot(x, y, 'g+');

    title(sprintf('Barrel distance: %.1f m', dist));
    
    % You may also want to plot and display other
    % diagnostic information such as the outlines
    % of connected regions, etc.
    hold off;
    pause;
end