function Xs = ukf_quat_sigma(X, P, Q, C)
%UKF_QUAT_SIGMA generates sigma points for quaternion and angular
%velocity

W       = sqrt(C) * chol(P + Q);

% Propagates quaternion
X_q     = X(1:4);
W_q     = [W(1:3,:), -W(1:3,:)];
alpha_W = vec2norm(W_q, 1);
e_W     = bsxfun(@rdivide, W_q, alpha_W);
e_W(isnan(e_W)) = 0;
q_W     = [cos(alpha_W/2); bsxfun(@times, e_W, sin(alpha_W/2))];
X_qi    = quatmultiply(X_q', q_W')';
Xs_q    = [X_q, X_qi];

% Propagates angular velocity
X_wb    = X(5:7); % bias part of state vector
W_wb   = [W(4:6,:) -W(4:6,:)];
Xs_wb  = [X_wb, bsxfun(@plus, X_wb, W_wb)];

% Concatenate sigma points
Xs      = [Xs_q; Xs_wb];
end