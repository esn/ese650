% Generate plots
close all
clear all
%% Plot for filtering
imu = load_imu('circle', 1);
h_fig = plot_imu([], imu, [], 'acc', 'b');
imu_filt = filter_imu(imu);
h_fig = plot_imu(h_fig, imu_filt, [], 'acc', 'r');
change_font(gcf, 12)
change_line(gcf, 2)
fig2pdf(gcf, '../report/fig/filter.pdf')

%% Plot for zero mean and unit variance
open('cluster.fig')
change_font(gcf, 12)
change_line(gcf, 2)
fig2pdf(gcf, '../report/fig/cluster.pdf')