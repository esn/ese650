classdef GMM < handle
    %GMM train a Gaussian Mixture Model on chosen color
    
    properties
        n_cluster  % number of cluster
        type       % type of feature
        cspace     % color space
        model      % trained gmm
    end
    
    methods
        % Constructor
        function obj = GMM(n_cluster, type, cspace)
            obj.n_cluster = n_cluster;
            obj.type = type;
            obj.cspace = cspace;
        end
        
        % gmm.train(im) train with a bunch of images
        function train(obj, im)
            fprintf('Select color for %s\n', obj.type);
            % convert im to cell
            if ~iscell(im), im = {im}; end
            % Initialize X
            X = [];
            for i = 1:numel(im)
                close all
                % Crop desired color on image
                bw = roipoly(im{i});
                % Convert to desired colorspace
                im_cs = GMM.trans_cs(im{i}, obj.cspace);
                [nr,nc,~] = size(im_cs);
                x = reshape(im_cs, nr*nc , []);
                x = x(bw,:);
                % Append to X
                X = [X; x];
            end
            X = X(1:4:end,:);
            X = double(X);
            % Train mixture model
            options = statset('Display', 'final');
            obj.model = gmdistribution.fit(X, obj.n_cluster, ...
                'Replicates', 5, 'SharedCov', false, 'Options', options);
        end
        
        % test
        function P = test(obj, im, vis)
            if nargin < 3, vis = false; end
            if ~iscell(im), im = {im}; end
            % Initialize P
            P = [];
            for i = 1:numel(im)
                % Convert to desired color space
                im_cs = GMM.trans_cs(im{i}, obj.cspace);
                [nr,nc,~] = size(im_cs);
                X = reshape(im_cs, nr*nc, []);
                X = double(X);
                [~,~,p] = obj.model.cluster(X);
                p = p * obj.model.PComponents(:);
                % Append to P
                P = [P p];
                if vis
                    title(obj.type)
                    subplot(1,2,1)
                    imshow(im{i});
                    subplot(1,2,2)
                    imagesc(reshape(p, nr, nc));
                    axis image;
                    title(obj.type)
                    pause
                end
            end
        end
    end
    
    methods (Static)
        im_cs = trans_cs(im, cs)
    end
    
end
