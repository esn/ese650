function [ imu_all ] = cat_data( data, gesture, num_data )
%CAT_ALL_DATA concatenate all imu data given gesture_list
% [ imu_all ] = cat_data( data, gesture, data_ind )
gesture_list = {'circle', 'figure8', 'fish', 'hammer', 'pend', 'wave'}; 

if nargin < 2, gesture = gesture_list; end
if nargin < 3, data_ind = 1:length(data(1).data); end

imu_all = [];
for i = 1:length(gesture)
    gesture_ind = strcmp(gesture{i}, gesture_list);
    for j = 1:length(data_ind)
        imu = data(gesture_ind).data(data_ind(j)).imu_proc;
        imu_all = [imu_all; imu];
    end
end

end
