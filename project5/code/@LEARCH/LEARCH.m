classdef LEARCH < handle
    %LEARCH
    
    properties
        train_data
        test_data
        w
        T
    end
    
    properties (Dependent = true)
        d
        n_train
        n_test
    end
    
    methods
        % Constructor
        function obj = LEARCH(train_data, test_data, T)
            obj.train_data = train_data;
            obj.test_data = test_data;
            obj.T = T;
        end
        
        % Train using LEARCH framework
        function w = train(obj, vis)
            % Initialize log-cost map to zero
            obj.w = zeros(obj.d,1);
            for t = 1:obj.T
                % Initialize data set to empty
                X = [];
                Y = [];
                for i = 1:obj.n_train
                    k = 1;
                    mdp = obj.train_data(i);
                    % Compute the loss-augmented costmap cl
                    cl = obj.genLossCostMap(mdp, k);
                    goal = mdp.goal(k,:);
                    start = mdp.start(k,:);
                    % Find the minimum cost loss-augmented path
                    [i_path, j_path] = obj.getMinCostPath(cl, start ,goal);
                    % Generage positive and negative examples
                    ind_pos = sub2ind([mdp.nr mdp.nc], i_path, j_path);
                    ind_neg = sub2ind([mdp.nr mdp.nc], mdp.policy{k}(:,1), mdp.policy{k}(:,2));
                    x_pos = mdp.F(ind_pos,:);
                    x_neg = mdp.F(ind_neg,:);
                    y_pos = ones(size(x_pos,1),1);
                    y_neg = -ones(size(x_neg,1),1);
                    X = [X; x_pos; x_neg];
                    Y = [Y; y_pos; y_neg];
                    % Visualization
                    if vis
                        subplot(1,2,1)
                        obj.train_data(i).plot(1);
                        hold on
                        plot(j_path, i_path, 'c.')
                        hold off
                        subplot(1,2,2)
                        imagesc(cl); colormap(jet)
                        title(sprintf('max: %3.3f, min: %3.3f', max(cl(:)), min(cl(:))))
                        axis image
                    end
                    pause
                end
                % Train a regressor or classifier on the collected data set
                % D to get h
%                 h = (X'*X)\X'*Y;
                option  = sprintf('-s %d -q -c %g', 1, 0.1);
                model = liblinear_train(Y, sparse(X), option);
                obj.w = obj.w + 0.1*model.w(:);
                disp(obj.w)
            end
            w = obj.w;
        end
        
        function test(obj)
            for i = 1:obj.n_test
                k = 1;
                mdp = obj.test_data(i);
                % Compute costmap c
                c = obj.genCostMap(mdp);
                goal = mdp.goal(k,:);
                start = mdp.start(k,:);
                [i_p, j_p] = obj.getMinCostPath(c, start ,goal);
                figure()
                subplot(1,2,1)
                mdp.plot();
                hold on
                plot(j_p, i_p, 'm.');
                hold off
                subplot(1,2,2)
                c = imadjust(c);
                imagesc(c); colormap(jet)
                axis image
                title(sprintf('max: %3.3f, min: %3.3f', max(c(:)), min(c(:))))
            end
        end
        
        function cl = genLossCostMap(obj, mdp, n)
            l = mdp.L{n};
            c = exp(mdp.F*obj.w);
            c = reshape(c, mdp.nr, mdp.nc, []);
            cl = c - l + 1;
        end
        
        function c = genCostMap(obj, mdp)
            c = exp(mdp.F*obj.w);
            c = reshape(c, mdp.nr, mdp.nc, []);
        end
        
        % Get methods
        function d = get.d(obj)
            d = size(obj.train_data(1).F, 2);
        end
        
        function n_train = get.n_train(obj)
            n_train = numel(obj.train_data);
        end
        
        function n_test = get.n_test(obj)
            n_test = numel(obj.test_data);
        end
    end
   
    methods (Static)
        function [i_p, j_p] = getMinCostPath(cost, start ,goal)
            ctg = dijkstra_matrix(cost, goal(1), goal(2));
            [i_p, j_p] = dijkstra_path(ctg, cost, start(1), start(2));
        end
    end
end

