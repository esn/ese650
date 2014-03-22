classdef MagicRobot < handle
    
    properties (Constant)
        enc_coeff = 2*pi/360;
    end
    
    properties
        c = 1.85  % width coefficient
        w = (311.15 + 476.25)/2000 % axle width
        r = 254/2000% wheel radius
        s  % robot state
        a  % parameter in noise
        u  % odometry
        s_hist
        k = 0
        
        h_traj
        h_car
        a_car
    end
    
    methods
        % Constructor
        function MR = MagicRobot(s, a, max_len)
            if nargin < 3, max_len = 5000; end
            if nargin < 2, a = [0.2, 0.2]; end
            if nargin < 1, s = zeros(3,1); end
            
            MR.w = MR.w * MR.c;
            MR.a = a;
            MR.s = s;
            MR.s_hist = zeros(3, max_len);
            MR.s_hist(:,1) = MR.s;
        end
        
        function u = enc2odom(MR, enc)
            dR = (enc(1) + enc(3)) / 2 * MR.enc_coeff * MR.r;
            dL = (enc(2) + enc(4)) / 2 * MR.enc_coeff * MR.r;
            alpha = (dR - dL) / MR.w;
            dC = (dR + dL) / 2;
            u(1) = dC;
            u(2) = alpha;
            MR.u = u;
        end
        
        % Motion methods
        function motion_model(MR)
            MR.s = MR.motion(MR.s, MR.u);
        end
        
        function p = sample_motion_model(MR, p)
            p = MR.motion(p, MR.u, MR.a);
        end
        
        % Loggin methos
        function append_hist(MR)
            MR.k = MR.k + 1;
            MR.s_hist(:,MR.k) = MR.s;
        end
        
        function truncate_hist(MR)
            MR.s_hist = MR.s_hist(:,1:MR.k);
        end
        
        % Visualization methods
        function plot_traj(MR, varargin)
            if isempty(MR.h_traj)
                hold on
                MR.h_traj = plot(MR.s_hist(1,1:MR.k), MR.s_hist(2,1:MR.k), varargin{:});
                hold off
            else
                set(MR.h_traj, 'XData', MR.s_hist(1,1:MR.k), ...
                    'YData', MR.s_hist(2,1:MR.k));
            end
            drawnow
        end
        
        function plot_car(MR, varargin)
            if isempty(MR.h_car)
                hold on
                MR.h_car(1) = plot(MR.s(1), MR.s(2), varargin{:});
                MR.h_car(2) = quiver(MR.s(1), MR.s(2), ...
                    0.3 * cos(MR.s(3)), 0.3 * sin(MR.s(3)), 0);
                hold off
                axis equal
            else
                set(MR.h_car(1), 'XData', MR.s(1), 'YData', MR.s(2));
                set(MR.h_car(2), 'XData', MR.s(1), 'YData', MR.s(2), ...
                    'UData', 0.3 * cos(MR.s(3)), 'VData', 0.3 * sin(MR.s(3)));
            end
            drawnow
        end
    end
    
    methods (Static)
        function s = motion(s, u, a)
        trans = u(1);
        alpha = u(2);
        x     = s(1);
        y     = s(2);
        theta = s(3);
        
        if nargin < 3
            noise_alpha1 = 0;
            noise_alpha2 = 0;
            noise_trans  = 0;
        else
            noise_trans  = normrnd(0, a(1)*abs(trans));
            noise_alpha1 = normrnd(0, a(2)*abs(alpha/2));
            noise_alpha2 = normrnd(0, a(2)*abs(alpha/2));
        end
        
        theta = theta  + alpha/2 + noise_alpha1;
        x = x + (trans + noise_trans) * cos(theta);
        y = y + (trans + noise_trans) * sin(theta);
        theta = theta + alpha/2 + noise_alpha2;
        
        s(1) = x;
        s(2) = y;
        s(3) = theta;
        end
    end
end
