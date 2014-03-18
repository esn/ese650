function [data] = load_data(data_id, data_path)
%LOAD_DATA load sensor data according to data_id
% [ data ] = load_data( data_id, data_path )

if nargin < 2, data_path = '../data/'; end

% imuRaw
data.imu = load(fullfile(data_path, sprintf('imuRaw%d.mat', data_id)));

% Hokuyo0
lidar = load(fullfile(data_path, sprintf('Hokuyo%d.mat', data_id)));
data.ldr = lidar.Hokuyo0;

% Encoders
enc = load(fullfile(data_path, sprintf('Encoders%d.mat', data_id)));
data.enc = enc.Encoders;

end