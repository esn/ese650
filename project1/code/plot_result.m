load result
[d_true, ind] = sort(dist_hist);
d_test = d_hist(ind);
figure(1);
plot(d_true, 'b-o', 'LineWidth', 2)
hold on
plot(d_test, 'r-+', 'LineWidth', 2)
hold off
grid on
legend('true', 'predict')
change_font(gcf ,12)