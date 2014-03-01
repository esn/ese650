gesture = 'circle';
[imu, t] = LoadImuData(gesture, 1);
line_color = lines(3);
h_fig = figure();
PlotImuData(h_fig, imu, t, 'acc', line_color(1,:));

sample_rate = 100;
cutoff_freq = 4;
Wn = cutoff_freq/(sample_rate/2);
n = 4;
[b, a] = butter(n, Wn);
imu_filtered = filtfilt(b, a, imu);
