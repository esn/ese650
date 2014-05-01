clear all
close all
clc
%%
[vmeans, eids, emeans, einfs] = ...
    read_graph('data/killian-v.dat', 'data/killian-e.dat');

x1 = vmeans(:,1);
x2 = vmeans(:,2);
z21 = emeans(:,1);

t1 = v2t(x1);
t2 = v2t(x2);

t21 = t2\t1;

z21_hat = t2v(t21);

disp(z21_hat)
disp(z21)