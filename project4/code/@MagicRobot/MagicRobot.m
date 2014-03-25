classdef MagicRobot < handle
    
    properties (Constant)
        enc_coeff = 2*pi/360;
    end
    
    properties
        c = 1.82  % width coefficient
        w = (311.15 + 476.25)/2000  % axle width
        w_eff
        r = 254/2000  % wheel radius
        l = 0.3  % robot length
        
        a  % parameter in noise
        u  % odometry
        s  % robot state
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
            if nargin < 2, a = [0.25, 5]; end
            if nargin < 1, s = zeros(3,1); end
            
            MR.w_eff = MR.w * MR.c;
            MR.a = a;
            MR.s = s(:);
            MR.s_hist = zeros(3, max_len);
            MR.s_hist(:,1) = MR.s;
        end
        
        function u = enc2odom(MR, enc)
            dR = (enc(1) + enc(3)) / 2 * MR.enc_coeff * MR.r;
            dL = (enc(2) + enc(4)) / 2 * MR.enc_coeff * MR.r;
            alpha = (dR - dL) / MR.w_eff;
            dC = (dR + dL) / 2;
            u(1) = dC;
            u(2) = alpha;
            MR.u = u;
        end
        
        % Motion methods
        function motion_model(MR)
            MR.s = MR.motion(MR.s, MR.u);
        end
        
        function update_state(MR, s)
            MR.s = s;
        end
        
        % Logging methods
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
            
        end
        
        function plot_car(MR, varargin)
            if isempty(MR.h_car)
                hold on
                MR.h_car(1) = plot(MR.s(1), MR.s(2), varargin{:});
                MR.h_car(2) = plot([MR.s(1), MR.s(1) + MR.l * cos(MR.s(3))], ...
                    [MR.s(2), MR.s(2) + MR.l * sin(MR.s(3))], '-');
                hold off
                axis equal
            else
                set(MR.h_car(1), 'XData', MR.s(1), 'YData', MR.s(2));
                set(MR.h_car(2), ...
                    'XData', [MR.s(1), MR.s(1) + MR.l * cos(MR.s(3))], ...
                    'YData', [MR.s(2), MR.s(2) + MR.l * sin(MR.s(3))]);
            end
        end
    end
    
    methods (Static)
        function s = motion(s, u, a)
            trans = u(1);
            alpha = u(2);
            x     = s(1,:);
            y     = s(2,:);
            theta = s(3,:);
            
            num_s = size(x,2);
            
            if nargin < 3
                noise_alpha = zeros(1, num_s);
                noise_trans  = zeros(1, num_s);
            else
                noise_trans  = normrnd(0, a(1)*abs(trans), 1, num_s);
                noise_alpha = normrnd(0, a(2)*abs(alpha/2), 1, num_s);
            end
            
            theta = theta + alpha/2 + noise_alpha/2;
            x = x + (trans + noise_trans) .* cos(theta);
            y = y + (trans + noise_trans) .* sin(theta);
            theta = theta + alpha/2 + noise_alpha/2;
            
            s(1,:) = x;
            s(2,:) = y;
            s(3,:) = theta;
        end
    end
end
