function [ u ] = enc2odom( enc )
%ENC2ODOM output odometry u = [R,alpha]
wheel_radius = 254 / 2000;
width_coeff = 1.85;
axle_width = (311.15 + 476.25) / 2000 * width_coeff;
enc_coeff = 2*pi/360;

dR = (enc(1) + enc(3)) / 2 * enc_coeff * wheel_radius;
dL = (enc(2) + enc(4)) / 2 * enc_coeff * wheel_radius;

alpha = (dR - dL) / axle_width;
dC = (dR + dL) / 2;

u(1) = dC;
u(2) = alpha;
end