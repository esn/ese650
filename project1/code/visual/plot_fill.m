function fill = plot_fill(data, id)
%PLOT_FILL
if nargin < 2 || isempty(id), id = 1:length(data); end

fill = zeros(1, length(id));
for i = 1:length(id)
    j = id(i);
    data_j = data(j);
    bw = data_j.bw;
    cc = bwconncomp(bw);
    rp = regionprops(cc);
    bb = rp(1).BoundingBox;
    area = rp(1).Area;
    fill(i) = area/(bb(3)*bb(4));
end

figure(1);
stem(id, fill, 'Filled', 'b', 'LineWidth', 2)
grid on
xlabel('Image')
ylabel('Pixel area')

end