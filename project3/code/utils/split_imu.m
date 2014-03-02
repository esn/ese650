function [ acc, omg ] = split_imu( imu )
% SPLIT_IMU split imu data into time, acceleration, angular velocity
% [ acc, omg ] = split_imu( imu )
assert(size(imu,2) == 6 || size(imu,2) == 9, 'Wrong imu dimension');

acc = imu(:,1:3);
omg = imu(:,4:6);

end
