function [ varargout ] = wrb2rpy_zyx( wRb )
%ROT2RPY_ZYX Convert rotation matrix from body to world to euler angles
% wRb = [cos(psi)*cos(theta), ...
%        cos(psi)*sin(phi)*sin(theta) - cos(phi)*sin(psi), ...
%        sin(phi)*sin(psi) + cos(phi)*cos(psi)*sin(theta);
%        cos(theta)*sin(psi), ...
%        cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta), ...
%        cos(phi)*sin(psi)*sin(theta) - cos(psi)*sin(phi);
%        -sin(theta), ...
%        cos(theta)*sin(phi), ...
%        cos(phi)*cos(theta)];

theta = -asin(wRb(3,1));
phi   = atan2(wRb(3,2)/cos(theta), wRb(3,3)/cos(theta));
psi   = atan2(wRb(2,1)/cos(theta), wRb(1,1)/cos(theta));

if nargout == 1 || nargout == 0
    varargout{1} = [phi; theta; psi];
elseif nargout == 3
    varargout{1} = phi;
    varargout{2} = theta;
    varargout{3} = psi;
end

end