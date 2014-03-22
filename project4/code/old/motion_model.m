function [ s ] = motion_model( s, u, a )
%MOTION_MODEL update motion model
trans = u(1);
alpha = u(2);
x     = s(1);
y     = s(2);
theta = s(3);

if nargin < 3
    noise_alpha1 = 0;
    noise_alpha2 = 0;
    noise_trans  = 0;
else
    noise_trans  = normrnd(0, a(1)*abs(trans));
    noise_alpha1 = normrnd(0, a(2)*abs(alpha/2));
    noise_alpha2 = normrnd(0, a(2)*abs(alpha/2));
end

theta = theta  + alpha/2 + noise_alpha1;
x = x + (trans + noise_trans) * cos(theta);
y = y + (trans + noise_trans) * sin(theta);
theta = theta + alpha/2 + noise_alpha2;

s(1) = x;
s(2) = y;
s(3) = theta;
end