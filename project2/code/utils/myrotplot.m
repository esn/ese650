function [ hpatch ] = myrotplot( R, hpatch )
% MYROTPLOT an improved version of rotplot that reuse previous patch
%   object if passed in
persistent vs f
if isempty(vs)
    lxyz = [3, 1.5, 1];
    v = [0 0 0; 1 0 0; 1 1 0; 0 1 0; ...
         0 0 1; 1 0 1; 1 1 1; 0 1 1]; % unit vertices
    f = [1 2 6 5; ...
         2 3 7 6; ...
         3 4 8 7; ...
         4 1 5 8; ...
         1 2 3 4; ...
         5 6 7 8];
    vs = bsxfun(@times, v - 0.5, lxyz);
end

fcolors = [1 1 1; 0 0 1; 1 1 1; 1 0 0; 1 1 1; 1 1 1];
falphas = [0; 1; 0; 1; 0; 0];
verts   = vs * R';
faces   = f;

if nargin < 2
    % plot R and get a new patch object
    hpatch = patch('Vertices', verts, 'Faces', faces, ...
                   'FaceColor', 'Flat', ...
                   'FaceVertexCData', fcolors, ...
                   'AlphaDataMapping', 'none', ...
                   'FaceAlpha', 'Flat', ...
                   'FaceVertexAlphaData', falphas);
    axis equal;
    axis([-2 2 -2 2 -2 2]);
    xlabel('x'); ylabel('y'); zlabel('z');
else
    % Modify current patch object
    set(hpatch, 'Vertices', verts);
end

end