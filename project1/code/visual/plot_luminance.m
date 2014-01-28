function lum_level = plot_luminance(data, id, thresh)
%PLOT_LUMINANCE
if nargin < 3, thresh = 100; end
if nargin < 2 || isempty(id), id = 1:length(data); end

lum_level = zeros(1, length(id));
for i = 1:length(id)
    j = id(i);
    data_j = data(j);
    L = data_j.lab(:,:,1);
    lum_level(i) = median(L(:));
end

figure();
hold on
stem(id(lum_level < thresh), lum_level(lum_level < thresh), 'Filled', 'b', 'LineWidth', 2)
stem(id(lum_level >= thresh), lum_level(lum_level >= thresh), 'Filled', 'r', 'LineWidth', 2)
hold off
grid on
xlabel('Image')
ylabel('Luminance level')

end