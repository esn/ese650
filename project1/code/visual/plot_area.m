function area = plot_area(data, id)
%PLOT_AREA
if nargin < 2 || isempty(id), id = 1:length(data); end

area = zeros(1, length(id));
for i = 1:length(id)
    j = id(i);
    data_j = data(j);
    bw = data_j.bw;
    area(i) = nnz(bw);
end

figure(1);
stem(id, area, 'Filled', 'b', 'LineWidth', 2)
grid on
xlabel('Image')
ylabel('Pixel area')

end