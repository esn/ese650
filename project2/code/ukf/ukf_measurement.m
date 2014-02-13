function [ Z ] = ukf_measurement( X )
%UKF_MEASUREMENT measurement model for ukf
%[ Z ] = ukf_measurement( X )

q = X(1:4);
omg = X(5:7);

Z_omg = omg;

g = [0; 0; 0; 1];
g_prime = quatmultiply(quatmultiply(q', g'), quatconj(q'));

Z_acc = g_prime(2:4)';
Z = [Z_acc; Z_omg];

end