gesture = 'circle';
imu1 = cat_data(train, {gesture});
imu2 = cat_data(valid, {gesture});
imu = [imu1; imu2];
acc = filter_imu(imu(:,1:3), 4, [0.5, 4]);
%%
% Get all acceleration
acc_all = [];
for i = 1:length(gesture_list)
    % Concatenate all training data for current gesture
    imu = cat_data(train, gesture_list(i));
    acc = imu(:,1:3);
    % filter with 4th oder butterworth and cutoff frequency of 4hz
    acc = filter_imu(acc);
    % down sample by 5
    acc = down_sample(acc);
    acc_all = [acc_all; acc];
end