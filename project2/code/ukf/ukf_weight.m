function [Wm, Wc, C] = ukf_weight(n, alpha, beta, kappa)
% UKF_WEIGHT generates ukf weights
% [Wm, Wc, C] = ukf_weight(n, alpha, beta, kappa)

lambda = alpha^2 * (n + kappa) - n;
C = n + lambda;
Wm = [lambda/C, 0.5/C + zeros(1, 2*n)];
Wc = Wm;
Wc(1) = Wc(1) + (1 - alpha^2 + beta);

end