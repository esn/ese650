function [ imu_down ] = down_sample( imu, step )
%DOWN_SAMP Summary of this function goes here
%   Detailed explanation goes here
assert(size(imu,2) == 3 || size(imu,2) == 6, 'Wrong imu dimension');
if nargin < 2, step = 5; end

imu_down = imu(1:step:end,:);

end
