function aratio = plot_aratio(data, id)
%PLOT_AREA
if nargin < 2 || isempty(id), id = 1:length(data); end

aratio = zeros(1, length(id));
for i = 1:length(id)
    j = id(i);
    data_j = data(j);
    bw = data_j.bw;
    cc = bwconncomp(bw);
    rp = regionprops(cc);
    bb = rp(1).BoundingBox;
    aratio(i) = bb(4)/bb(3);
end

figure(1);
stem(id, aratio, 'Filled', 'b', 'LineWidth', 2)
grid on
xlabel('Image')
ylabel('Pixel area')

end