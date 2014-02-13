function [ Pk_bar ] = ukf_apriori_state_cov( Ys, Y, Wc )
%UKF_APRIORI_STATE_COV calculates a priori state covariance



Pk_bar = W * diag(Wc) * W';
end