function [ imu, t ] = load_imu( gesture, data_num )
% LOAD_IMU load imu data of a gesture into t and imu = [acc; omg]
% [ imu, t ] = load_imu( gesture, data_num )
%   gesture  - circle  figure8  fish  hammer  pend  wave
%   data_num - number of data

% Get path for the training data
current_path = fileparts(mfilename('fullpath'));
train_path = fullfile(current_path, '../../train');

% Get all gesture
gesture_listing = dir(train_path);
gesture_list = {};
for i = 1:length(gesture_listing)
    if ~strcmp(gesture_listing(i).name, '.') && ...
       ~strcmp(gesture_listing(i).name, '..') && ...
       gesture_listing(i).isdir
        gesture_list{end+1} = gesture_listing(i).name;
    end
end

% Validate gesture input
if ~any(strcmp(gesture, gesture_list)),
    fprintf('Wrong gesture %s, please use the following:\n', gesture);
    disp(gesture_list)
    imu = [];
    t = [];
    return
end
gesture_path = fullfile(train_path, gesture);

% Get all data name
data_listing = dir(gesture_path);
data_list = {};
for i = 1:length(data_listing)
    if ~data_listing(i).isdir
        data_list{end+1} = data_listing(i).name;
    end
end
if isnumeric(data_num)
    data_name = data_list{data_num};
else
    data_name = sprintf('imu0%s', data_num);
end

% Validate data name input
if ~any(strcmp(data_name, data_list))
    fprintf('Error loading %s, please use the following:\n', data_name);
    disp(data_list)
    imu = [];
    t = [];
    return
end
data_path = fullfile(gesture_path, data_name);

% Load data
data = load(data_path);
t    = data(:,1);
imu  = data(:,2:7);
fprintf('Load %s %s\n', gesture, data_name);

end
