function [ Pk_bar, W ] = ukf_apriori_state_cov( Ys, Y, Wc )
%UKF_APRIORI_STATE_COV calculates a priori state covariance

q_mean = Y(1:4);
qs = Ys(1:4,:);
omg_mean = Y(5:7);

omg_W = bsxfun(@minus, Ys(5:7,:), omg_mean);
q_W = quatmultiply(qs', quatconj(q_mean'))';
r_W = q_W(2:4,:);

W = [r_W; omg_W];
Pk_bar = W * diag(Wc) * W';
end