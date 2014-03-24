classdef MonteCarlo < handle
    %MONTECARLO Localization algorithm
    
    properties
        p  % particles
        w
        n_p
        motion = false
        measure = false
        best_p
        h_p
    end
    
    methods
        % Constructor
        function MC = MonteCarlo(n_p)
            MC.n_p = n_p;
            MC.p = zeros(3,MC.n_p);
            MC.w = ones(1,MC.n_p) ./ MC.n_p;
        end
        
        % Sampling methods
        function sample_motion_model(MC, u, a)
            MC.p = MagicRobot.motion(MC.p, u, a);
            MC.motion = true;
        end
        
        % Measurement methods
        function measurement_model(MC, map, xy_bound, res, ldr, eul)
            x_im = xy_bound(1):res:xy_bound(2);
            y_im = xy_bound(3):res:xy_bound(4);
            x_win = -0.5:res:0.5;
            y_win = -0.5:res:0.5;
            cs = zeros(1,MC.n_p);
            c_ind = zeros(1,MC.n_p);
            for i = 1:MC.n_p
                eul(3) = MC.p(3,i);
                ldr.transform_range(MC.p(:,i), rpy2wrb_xyz(eul));
                ldr.prune_range();
                p_range = [ldr.p_range([2 1],:); zeros(1, length(ldr.p_range))];
                c = map_correlation(map, x_im, y_im, p_range, x_win, y_win);
                [cs(i), c_ind(i)] = max(c(:));
            end
            [max_c, max_ind] = max(cs);
            ind = c_ind(max_ind);  % Find the ind of the highest c
            [row, col] = ind2sub(size(c), ind);  % find row and col
            x = ((size(c,2)/2) - col) * res;  % convert row and col to x and y
            y = ((size(c,2)/2) - row) * res;
            MC.best_p = MC.p(:,max_ind);
            MC.w = MC.w .* cs;
            MC.renormailze();
            MC.measure = true;
        end
        
        function resample(MC)
            MC.p = repmat(MC.best_p, 1, MC.n_p);
            MC.w = ones(1,MC.n_p) ./ MC.n_p;
            MC.measure = false;
            MC.motion = false;
        end
        
        function renormailze(MC)
            MC.w = MC.w / norm(MC.w, 2);
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

