function [ X_k1 ] = ukf_process( X_k, dt )
%UKF_PROCESS process model of ukf
%[ X_k1 ] = ukf_process( X_k, dt )

q_k = X_k(1:4);
w_k = X_k(5:7);

alpha_d = norm(w_k,2)*dt;
e_d = w_k/norm(w_k,2);
% e_d(isnan(e_d)) = 0;
q_d = [cos(alpha_d/2); e_d*sin(alpha_d/2)];

q_k1 = quatmultiply(q_k', q_d')';
w_k1 = w_k;

X_k1 = [q_k1; w_k1];
end