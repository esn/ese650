function [ Ys ] = ukf_process_ut( Xs, dt )
%UKF_PROCESS_UT Unscented transform for ukf process model
[~, n_sigma] = size(Xs);
Ys = zeros(size(Xs));
for i = 1:n_sigma
    Ys(:,i) = ukf_process(Xs(:,i), dt);
end

end