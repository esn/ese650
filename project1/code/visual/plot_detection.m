function plot_detection( rp )
plot(rp.Centroid(1), rp.Centroid(2), 'r+', 'MarkerSize', 8, 'LineWidth', 2)
rectangle('Position', rp.BoundingBox, 'EdgeColor', 'g', 'LineWidth', 2)
end

