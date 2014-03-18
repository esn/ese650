function [X_k1] = ukf_process(X_k, U, dt)
%UKF_PROCESS process model of ukf
%[ X_k1 ] = ukf_process( X_k, dt )

q_k = X_k(1:4);
b_k = X_k(5:7);
w_k = U + b_k;

alpha_d = norm(w_k,2)*dt;
e_d = w_k / norm(w_k,2);
% e_d(isnan(e_d)) = 0;
q_d = [cos(alpha_d/2); e_d*sin(alpha_d/2)];

q_k1 = quatmultiply(q_k', q_d')';
b_k1 = b_k;

X_k1 = [q_k1; b_k1];
end