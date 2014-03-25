
num_vals = 500;
addpath('utils')
data_id = 3;
data = load_data(data_id, '../Project4_Test', true);
% data_id = 20;
% data = load_data(data_id);
acc = data.imu.vals(1:3,1:num_vals);
omg = data.imu.vals(4:6,1:num_vals);
acc_mean = mean(acc, 2);
omg_mean = mean(omg, 2);