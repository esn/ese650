pixel_orig = 1200*1600;
pixel_reduced = 300*400;
labels = {'subsampled', 'original'};
figure()
barh([pixel_reduced, pixel_orig], 'FaceColor',[1 0.5 0]);
title('Pixels to process before and after subsampling')
set(gca, 'YTickLabel', labels);
ylim([0 3])
change_font(gcf, 12)
