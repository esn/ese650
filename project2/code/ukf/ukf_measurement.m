function [ Z ] = ukf_measurement( X )
%UKF_MEASUREMENT measurement model for ukf
%[ Z ] = ukf_measurement( X )

q   = X(1:4);

g   = [0; 0; 0; 1];
g_q = quatmultiply(quatmultiply(quatconj(q'), g'), q');

Z   = g_q(2:4)';

end