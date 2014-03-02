function [ imu ] = scale_imu( imu, mean_imu, std_imu )
%SCALE_IMU scale imu data to zero mean and unit variance
% [ imu ] = scale_imu( imu, mean_imu, std_imu )

imu = bsxfun(@minus, imu, mean_imu);
imu = bsxfun(@rdivide, imu, std_imu);

end