function beautify( h )
%BEAUTIFY 

num_handle = numel(h);

for i_handle = 1:num_handle
    figure(h(i_handle));
    set(gca, 'Box', 'On');
    grid on;
    axis equal;
    set(findall(gcf, '-property', 'FontSize'), 'FontSize', 12);
end

end

