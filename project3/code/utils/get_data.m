function [ data ] = get_data( rel_path, gesture_list, imu_id )
%GET_TEST_DATA gather all test data into a struct

% Get path for current function and data
func_path = fileparts(mfilename('fullpath'));
data_path = fullfile(func_path, rel_path);

if ~iscell(gesture_list), gesture_list = {gesture_list}; end
if strcmp(gesture_list{1}, 'all') && length(gesture_list) == 1,
    % Get all gestures
    gesture_list = get_gesture(data_path);
end

data = struct;
for i = 1:length(gesture_list)
    gesture_path = fullfile(data_path, gesture_list{i});
    if numel(imu_id) == 1 && imu_id == 0
        [imu_id, imu_list] = get_imu(gesture_path);
    else
        [~, imu_list] = get_imu(gesture_path);
    end
    for j = 1:length(imu_id)
        imu_path = fullfile(gesture_path, imu_list{imu_id(j)});
        % Load imu data and sort into struct
        imu = load(imu_path);
        data(i).data(j).gesutre = gesture_list{i};
        data(i).data(j).imu     = imu(:,2:7);
        data(i).data(j).t       = imu(:,1);
        fprintf('Load %s %s\n', gesture_list{i}, imu_list{imu_id(j)});
    end
end

end

% get all imu id from gesture path
function [imu_id, imu_list] = get_imu( gesture_path )
imu_listing = dir(gesture_path);
imu_list = {};
for i = 1:length(imu_listing)
    if ~imu_listing(i).isdir
        imu_list{end+1} = imu_listing(i).name;
    end
end
imu_id = 1:length(imu_list);
end

% get all gesture list from data path
function gesture_list = get_gesture( data_path )
gesture_listing = dir(data_path);
gesture_list = {};
for i = 1:length(gesture_listing)
    if ~strcmp(gesture_listing(i).name, '.') && ...
            ~strcmp(gesture_listing(i).name, '..') && ...
            gesture_listing(i).isdir
        gesture_list{end+1} = gesture_listing(i).name;
    end
end
end