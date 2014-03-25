function [data] = load_data(data_id, data_path, is_test)
%LOAD_DATA load sensor data according to data_id
% [ data ] = load_data( data_id, data_path )

if nargin < 2, data_path = '../data/'; end
if nargin < 3, is_test = false; end
if is_test
    posfix = '_test';
else
    posfix = '';
end
% imuRaw
data.imu = load(fullfile(data_path, sprintf('imuRaw%s%d.mat', posfix, data_id)));

% Hokuyo0
lidar = load(fullfile(data_path, sprintf('Hokuyo%s%d.mat', posfix, data_id)));
data.ldr = lidar.Hokuyo0;

% Encoders
enc = load(fullfile(data_path, sprintf('Encoders%s%d.mat', posfix, data_id)));
data.enc = enc.Encoders;

end