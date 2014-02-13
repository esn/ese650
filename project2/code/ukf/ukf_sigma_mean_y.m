function [ Y ] = ukf_sigma_mean_y( Ys, Wm )
%UKF_SIGMA_MEAN calculate quaternion mean by the barycentric mean with
%renormalization
%[ Y ] = ukf_sigma_mean( Ys, Wm )

Ys_q = Ys(1:4,:);
Ys_q_wsum = sum(bsxfun(@times, Ys_q, Wm), 2);
Y_q = Ys_q_wsum / norm(Ys_q_wsum,2);

Ys_omg = Ys(5:7,:);
Y_omg = mean(Ys_omg, 2);

Y = [Y_q; Y_omg];
end