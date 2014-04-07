function im_cs = trans_cs(im, cs)

if nargin < 2, cs = 'rgb'; end
im_cs = cell(0);
for i = 1:numel(im)
    switch cs
        case 'hsv'
            im_cs{i} = rgb2hsv(im{i});
        case 'ycbcr'
            im_cs{i} = rgb2ycbcr(im{i});
        otherwise
            im_cs{i} = im{i};
    end
end

end