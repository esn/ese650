classdef MonteCarlo < handle
    %MONTECARLO Localization algorithm

    properties
        p  % particles
        w
        n_p
        w_eff_thresh
        motion = false
        measure = false
        best_p
        h_p
    end

    methods
        % Constructor
        function MC = MonteCarlo(n_p)
            MC.n_p = n_p;
            MC.w_eff_thresh = sqrt(MC.n_p);
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
            map(map < -25) = -25;
            x_im = xy_bound(1):res:xy_bound(2);
            y_im = xy_bound(3):res:xy_bound(4);
            x_win = [-1:1] * res;
            y_win = [-1:1] * res;
            cs = zeros(1,MC.n_p);
            cind = zeros(1,MC.n_p);
            for i = 1:MC.n_p
                eul(3) = MC.p(3,i);
                ldr.transform_range(MC.p(:,i), eul);
                ldr.prune_range();
                p_range = [ldr.p_range([2 1],:); ...
                    zeros(1, length(ldr.p_range))];
                c = map_correlation(map, x_im, y_im, p_range, x_win, y_win);
                [cs(i), cind(i)] = max(c(:));
            end

            if sum(cs) > 0
                MC.w = MC.w .* cs;
            end
            [~, max_ind] = max(cs);
            %             [row, col] = ind2sub([1 1]*length(x_win), cind(max_ind));
            %             x = x_win(col);
            %             y = y_win(row);
            MC.best_p = MC.p(:,max_ind);
            MC.renormailze_w();
            MC.measure = true;
        end

        function resample(MC)
            w_eff = sum(MC.w)^2 / sum(MC.w.^2);
            % resample
            if w_eff < MC.n_p * 0.2
                new_ind = resample(MC.w, MC.n_p);
                MC.p = MC.p(:,new_ind);
                MC.w = ones(1,MC.n_p) ./ MC.n_p;
            end
            MC.measure = false;
            MC.motion = false;
        end

        function renormailze_w(MC)
            MC.w = MC.w / sum(MC.w);
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
