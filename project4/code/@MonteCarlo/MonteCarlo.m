classdef MonteCarlo < handle
    %MONTECARLO Localization algorithm
    
    properties
        p  % particles
        w
        motion = false
        measure = false
        best_p
        h_p
    end
    
    methods
        % Constructor
        function MC = MonteCarlo(n_p)
            MC.p = zeros(3,n_p);
            MC.w = ones(1,n_p) ./n_p;
        end
        
        % Sampling method
        function sample_motion_model(MC, u, a)
            MC.p = MagicRobot.motion(MC.p, u, a);
        end
        
        % Visualization methods
        function plot_particle(MC, varargin)
            if isempty(MC.h_p)
                hold on
                MC.h_p = plot(MC.p(1,:), MC.p(2,:), varargin{:});
                hold off
            else
                set(MC.h_p, 'XData', MC.p(1,:), ...
                    'YData', MC.p(2,:));
            end
        end
        
    end
    
end

