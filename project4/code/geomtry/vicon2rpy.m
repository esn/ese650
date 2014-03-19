function euler = vicon2rpy(rots)
%VICON2RPY converts rotation matrices in the form of 3x3xN to euler angles

n_rots = size(rots, 3);
euler = zeros(3, n_rots);
for i = 1:n_rots
    euler(:,i) = wrb2rpy_zyx(rots(:,:,i));
end

end