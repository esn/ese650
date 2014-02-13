function [ Zs ] = ukf_measurement_ut( Ys )
%UKF_MEASUREMENT_UT Unscented transform for ukf measurement model
Zs = zeros(size(Ys,1) - 1, size(Ys,2));
n_sigma = size(Ys,2);
for i = 1:n_sigma
    Zs(:,i) = ukf_measurement(Ys(:,i));
end

end