function [ data ] = process_imu( data )
%PROCESS_IMU filter and downsample imu data
% [ data ] = process_imu( data )

for i = 1:length(data)
  for j = 1:length(data(i).data)
    imu = filter_imu(data(i).data(j).imu);  % Lowpass filter
    imu = down_sample(imu);                 % Down sample
    data(i).data(j).imu_proc = imu;
  end
end

end