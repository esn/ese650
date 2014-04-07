function im_cs = trans_cs(im, cs)
% TRANS_CS transform image to cs colorspace
if nargin < 2, cs = 'rgb'; end
switch cs
    case 'hsv'
        im_cs = rgb2hsv(im);
    case 'ycbcr'
        temp = rgb2ycbcr(im);
        im_cs = temp(:,:,2:3);
    case 'lab'
        cform = makecform('srgb2lab');
        temp = applycform(im, cform);
        im_cs = temp(:,:,2:3);
    otherwise
        im_cs = im;
end

end