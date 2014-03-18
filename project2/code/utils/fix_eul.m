function [ eul ] = fix_eul( eul )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

num_data = size(eul,2);
for i = 1:size(eul,1)
    for j = 1:num_data - 1
        if abs(eul(i,j+1) - eul(i,j)) > 1.9 * pi
            eul(i,j+1) = eul(i,j+1) - sign(eul(i,j+1) - eul(i,j)) * 2 * pi;
        end
    end
end
