% Test rotplot
clear all; close all; clc;

%% Compare with provide rotplot
figure()
R1 = eye(3);
R2 = [0 0 1; 0 1 0; 1 0 0];
R3 = [sqrt(2)/2, -sqrt(2)/2, 0; sqrt(2)/2, sqrt(2)/2, 0; 0 0 1];
R = {R1, R2, R3};
num_test = length(R);
for i = 1:num_test
    subplot(num_test, 2, 2*i - 1)
    rotplot(R{i});
    title('rotplot');
    subplot(num_test, 2, 2*i)
    myrotplot(R{i});
    title('myrotplot');
end

%% Test animation
figure()
load ../vicon/viconRot1
ts = ts - ts(1);
for i = 1:length(rots)
    tic
    if i == 1
        hpatch = myrotplot(rots(:,:,i));
        htitle = title(sprintf('t = %3.3f', ts(i) - ts(1)));
        dt = 0;
    else
        myrotplot(rots(:,:,i), hpatch);
        set(htitle, 'String', sprintf('t = %3.3f', ts(i) - ts(1)));
        dt = ts(i) - ts(i - 1);
    end
    drawnow;
    t = toc;
    if (t < dt)
        pause(dt - t);
    end
end