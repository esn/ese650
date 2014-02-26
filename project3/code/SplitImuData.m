function [ t, acc, omg, mag ] = SplitImuData( imu )
% SPLITIMUDATA split imu data into time, acceleration, angular velocity
% and magnotometer readings
assert(size(imu,2) == 10, 'Wrong imu dimension');

t   = imu(1,:);
acc = imu(2:4,:);
omg = imu(5:7,:);
mag = imu(8:10,:);

end
