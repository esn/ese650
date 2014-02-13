function [ X ] = ukf_kalman_update( X, V, K )
%UKF_KALMAN_UPDATE kalman update on the state vector

U = K * V;
U_rot = U(1:3);
U_omg = U(4:6);

X_q   = X(1:4);
alpha_U = norm(U_rot,2);
e_U = U_rot / norm(U_rot,2);
q_U = [cos(alpha_U/2); e_U * sin(alpha_U/2)];
X_q = quatmultiply(X_q', q_U')';

X_omg = X(5:7);
X_omg = X_omg + U_omg;

X = [X_q; X_omg];

end