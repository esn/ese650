function [ Ys ] = ukf_process_ut( Xs, dt )
%UKF_PROCESS_UT Unscented transform for ukf process model
[nstate, nsigma] = size(Xs);
Y = zeros(nstate,1);
Ys = zeros(size(Xs));
for i = 1:nsigma
    Ys(:,i) = ukf_process(Xs(:,i), dt);
end

end
% function [Y, Ys, S, Yd] = ukf_ut1(f, Xs, U, Rs, dt, Wm, Wc)
% % Unscented transform
% [L, n] = size(Xs);
% Y = zeros(L, 1);
% Ys = zeros(L, n);
% for k = 1:n
%     Ys(:,k) = f(Xs(:,k), U, Rs(:,k), dt);
%     Y = Y + Wm(k) * Ys(:,k);
% end
% Yd = bsxfun(@minus, Ys, Y);
% S = Yd * diag(Wc) * Yd';
% end