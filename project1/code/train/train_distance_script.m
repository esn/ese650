%% Train barrel model [aspect_ratio, fill_percentage]
load train
for i = 1:length(train)
    cc = bwconncomp(train(i).bw);
    rp = regionprops(cc);
    rp = rp(1);
    ar(i) = sqrt(rp.Area);
    w(i) = rp.BoundingBox(3);
    h(i) = rp.BoundingBox(4);
    Y(i) = 1/train(i).d;
end

X = [ar(:) w(:) h(:)];
W = inv(X'*X+500*eye(size(X,2)))*X'*Y(:);
dist_model.w = W;
save('dist_model.mat', 'dist_model')