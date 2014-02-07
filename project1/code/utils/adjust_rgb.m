function data = adjust_rgb( data, id )
if nargin < 2, id = 1:length(data); end
for i = 1:length(id)
    j = id(i);
    
    rgb = sqrt(im2double(data(j).im));
    rgb = im2uint8(rgb);
    data(j).rgb = rgb;

end
end