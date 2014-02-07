function x_n = normalize(x)
x_n = (x - min(x(:)))/max(x(:));
end