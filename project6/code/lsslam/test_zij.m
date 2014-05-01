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

%%
k = 150;
id_i = eids(1,k);
id_j = eids(2,k);

v_i = vmeans(:,id_i);
v_j = vmeans(:,id_j);
z_ij = emeans(:,k);

zt_ij = v2t(z_ij);
vt_i = v2t(v_i);
vt_j = v2t(v_j);

f_ij = inv(vt_i)*vt_j;

theta_i = v_i(3);
ti = v_i(1:2,1);
tj = v_j(1:2,1);
dt_ij = tj - ti;

si = sin(theta_i);
ci = cos(theta_i);

A = [-ci, -si, [-si, ci]*dt_ij; si, -ci, [-ci, -si]*dt_ij; 0, 0, -1 ];
B = [ ci, si, 0 ; -si, ci, 0 ; 0, 0, 1 ];

ztinv = inv(zt_ij);
e = t2v(ztinv*f_ij);

ztinv(1:2,3) = 0;
A = ztinv*A;
B = ztinv*B;

disp([A B e])

%%
T_i = v2t(v_i);
T_j = v2t(v_j);
R_i = T_i(1:2,1:2);
Z_ij = v2t(z_ij);
R_z = Z_ij(1:2,1:2);
dR_i = [-si ci; -ci -si]';
A = [-R_z'*R_i' R_z'*dR_i'*dt_ij; 0 0 -1];
B = [R_z'*R_i' [0;0]; 0 0 1];
e = t2v(inv(Z_ij)*inv(T_i)*T_j);
disp([A B e])
