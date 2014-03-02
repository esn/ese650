function [ imu_down ] = down_sample( imu_orig, step )
%DOWN_SAMP Summary of this function goes here
%   Detailed explanation goes here
assert(size(imu_orig,2) == 3 || size(imu_orig,2) == 6, 'Wrong imu dimension');
if nargin < 2, step = 5; end

imu_down = imu_orig(1:step:end,:);

end
