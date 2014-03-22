function [ p_range ] = transform_range( s, wRb, bTs, range, angle )

bHs = trans(bTs);
wHb = trans([s(1) s(2) 0]) * [wRb zeros(3,1); zeros(1,3) 1];
x_range = (range .* cos(angle))';
y_range = (range .* sin(angle))';
p_range = wHb * bHs * [x_range; y_range; zeros(size(x_range)); ones(size(x_range))];

end