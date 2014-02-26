function [ imu ] = LoadImuData( gesture, data_num, path )
% LOAD_DATA load imu data of a gesture
%   gesture  - circle  figure8  fish  hammer  pend  wave
%   data_num - number of data

% Validate gesture type
gesture_list = {'circle', 'figure8', 'fish', 'hammer', 'pend', 'wave'};
if ~any(strcmp(gesture, gesture_list)),
    disp('Wrong gesture specified, please use one of the following.')
    disp(gesture_list)
    return
end

% Get path for the training data
current_path = fileparts(mfilename('fullpath'));
train_path = fullfile(current_path, '../train');
gesture_path = fullfile(train_path, gesture);

% Get all data name
file_listing = dir(gesture_path);
for i = 1:length(file_listing)
    if ~file_lisitng(i).isdir
        data_list{i} = file_lisitng{i}.name;
    end
end
data_name = sprintf('imu%02d', data_num);

% Validate data name
if ~any(strcmp(data, data_list))
    disp('Wrong specified, please use one of the following.')
    disp(data_list)
end
data_path = fullfile(gesture_path, data_name);

% Load data
try
    imu = load(data_path);
    fprintf('Load %s %s\n', gesture, data_name);
catch
    imu = [];
    disp('Wrong data number, please use the following');
end

end
