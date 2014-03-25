global MAP

hokuyoFile = '../data/Hokuyo20.mat';

load(hokuyoFile);

MAP.res   = 0.05; %meters

MAP.xmin  = -20;  %meters
MAP.ymin  = -20;
MAP.xmax  =  20;
MAP.ymax  =  20;


%dimensions of the map
MAP.sizex  = ceil((MAP.xmax - MAP.xmin) / MAP.res + 1); %cells
MAP.sizey  = ceil((MAP.ymax - MAP.ymin) / MAP.res + 1);

MAP.map = zeros(MAP.sizex,MAP.sizey,'int8');


%assuming initial pose of x=0,y=0,yaw=0, put the first scan into the map
%also, assume that roll and pitch are 0 (not true in general - use IMU!)


%make the origin of the robot's frame at its geometrical center

%sensor to body transform
Tsensor = trans([0 0 0])*rotz(0)*roty(0)*rotx(0);

%transform for the imu reading (assuming zero for this example)
Timu = rotz(0)*roty(0)*rotx(0);
Timu_rot = rotz(0)*roty(0)*rotx(0);
%body to world transform (initially, one can assume it's zero)
Tpose   = trans([0 0 0]);

%full transform from lidar frame to world frame
T = Tpose*Timu*Tsensor;

%xy position in the sensor frame
xs0 = (Hokuyo0.ranges(1:2:end,1).*cos(Hokuyo0.angles(1:2:end)))';
ys0 = (Hokuyo0.ranges(1:2:end,1).*sin(Hokuyo0.angles(1:2:end)))';

%convert to body frame using initial transformation
X = [xs0;ys0;zeros(size(xs0)); ones(size(xs0))];
Y=T*X;

Y_rot = Tpose*Timu_rot*Tsensor*X;
%transformed xs and ys
xs1 = Y(1,:);
ys1 = Y(2,:);

%convert from meters to cells
xis = round((xs1 - MAP.xmin) ./ MAP.res);
yis = round((ys1 - MAP.ymin) ./ MAP.res);

%check the indices and populate the map
indGood = (xis > 1) & (yis > 1) & (xis < MAP.sizex) & (yis < MAP.sizey);
inds = sub2ind(size(MAP.map),yis(indGood),xis(indGood));
[x_cl, y_cl] = getMapCellsFromRay(MAP.xmax/MAP.res, MAP.ymax/MAP.res, ...
    xis(indGood), yis(indGood));
inds_cl = sub2ind(size(MAP.map), y_cl, x_cl);
MAP.map(inds) = 120;
% MAP.map(inds_cl) = 0;


%compute correlation
x_im = MAP.xmin:MAP.res:MAP.xmax; %x-positions of each pixel of the map
y_im = MAP.ymin:MAP.res:MAP.ymax; %y-positions of each pixel of the map

x_range = [-4:4] * MAP.res;
y_range = [-4:4] * MAP.res;
map = MAP.map;
map(map < 0) = 0;
c = map_correlation(map,x_im,y_im,Y_rot([2 1 3],:),x_range,y_range);
max(c(:))
%plot original lidar points
figure(1);
plot(xs1,ys1,'.')
axis equal

%plot map
figure(2);
imshow(-MAP.map);
axis xy
hold on
plot((Y(1,:) + MAP.xmax)/MAP.res, (Y(2,:) + MAP.ymax)/MAP.res, 'r.')
plot((Y_rot(1,:) + MAP.xmax)/MAP.res, (Y_rot(2,:) + MAP.ymax)/MAP.res, 'g.')

%plot correlation
figure(3);
surf(c)
