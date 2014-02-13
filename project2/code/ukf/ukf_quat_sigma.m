function Xs = ukf_quat_sigma(X, P, Q, C)
%UKF_QUAT_SIGMA generates sigma points for quaternion and angular
%velocity

W = sqrt(C) * chol(P + Q);

% Propagates quaternion
X_q = X(1:4);
W_q = [W(1:3,:), -W(1:3,:)];
alpha_W = vec2norm(W_q, 1);
e_W = bsxfun(@rdivide, W_q, alpha_W);
e_W(isnan(e_W)) = 0;
q_W = [cos(alpha_W); bsxfun(@times, e_W, sin(alpha_W))];
X_qi = zeros(size(q_W));
for i = 1:size(q_W, 2)
    X_qi(:,i) = quatmultiply(X_q', q_W(:,i)')';
end
Xs_q = [X_q, X_qi];

% Propagates angular velocity
X_omg  = X(5:7); % omega part of state vector
W_omg  = [W(4:6,:) -W(4:6,:)];
Xs_omg = [X_omg, bsxfun(@plus, X_omg, W_omg)];

% Concatenate sigma points
Xs = [Xs_q; Xs_omg];
end