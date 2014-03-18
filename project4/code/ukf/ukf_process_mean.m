function [Y] = ukf_process_mean(Ys, Wm)
%UKF_PROCESS_MEAN calculate quaternion mean by the barycentric mean with
%renormalization
%[ Y ] = ukf_sigma_mean( Ys, Wm )

Ys_q = Ys(1:4,:);
Ys_q_s = sum(bsxfun(@times, Ys_q, Wm), 2); % barycentric mean
Y_q = Ys_q_s / norm(Ys_q_s, 2); % renormalization

Ys_b = Ys(5:7,:);
Y_b = mean(Ys_b, 2);

Y = [Y_q; Y_b];
end