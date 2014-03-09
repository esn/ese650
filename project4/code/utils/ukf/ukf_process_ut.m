function [ Ys ] = ukf_process_ut( Xs, U, dt )
%UKF_PROCESS_UT Unscented transform for ukf process model
n_sigma = size(Xs,2);
Ys = zeros(size(Xs));
for i = 1:n_sigma
    Ys(:,i) = ukf_process(Xs(:,i), U, dt);
end

end