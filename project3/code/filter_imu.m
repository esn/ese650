function [ imu_filt ] = filter_imu( imu_raw, n, Wc )
% FILTER_IMU filter imu data using a butterworth filter
% [ imu_filt ] = filter_imu( imu_raw, n, Wc )
if nargin < 3, Wc = 4; end
if nargin < 2, n = 3; end

fs = 100; % sample rate
Wn = Wc/(fs/2);  % normailzed cutoff frequency
[b, a] = butter(n, Wn);
imu_filt = filtfilt(b, a, imu_raw);

end
