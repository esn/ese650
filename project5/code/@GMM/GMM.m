classdef GMM < handle
    %GMM
    
    properties
        n_cluster
        type
        cspace
        model
    end
    
    methods
        % Constructor
        function obj = GMM(n_cluster, type, cspace)
            obj.n_cluster = n_cluster;
            obj.type = type;
            obj.cspace = cspace;
        end
        
        % train
        function train(obj, im)
            % Convert to desired colorspace
            X = [];
            for i = 1:numel(im)
                close all
                bw = roipoly(im{i});
                im_cs = GMM.trans_cs(im{i}, obj.cspace);
                [nr,nc,~] = size(im_cs);
                pixels = reshape(im_cs, nr*nc , []);
                pixels = pixels(bw,:);
                X = [X; pixels];
            end
            X = X(1:3:end,:);
            X = double(X);
            options = statset('Display', 'final');
            obj.model = gmdistribution.fit(X, obj.n_cluster, ...
                'Replicates', 5, 'SharedCov', false, 'Options', options); 
        end
        
        % test
        function P = test(obj, im, vis)
            if nargin < 3, vis = false; end
            P = [];
            
            for i = 1:numel(im)
                im_cs = GMM.trans_cs(im{i}, obj.cspace);
                [nr,nc,~] = size(im_cs);
                X = reshape(im_cs, nr*nc, []);
                X = double(X);
                [~,~,p] = obj.model.cluster(X);
                p = p * obj.model.PComponents(:);
                P = [P p];
                if vis
                    figure(i)
                    title(obj.type)
                    subplot(1,2,1)
                    imshow(im{i});
                    subplot(1,2,2)
                    imagesc(reshape(p, nr, nc));
                    axis image;
                    title(obj.type)
                end
            end
            pause
        end
    end
    
    methods (Static)
        im_cs = trans_cs(im, cs)
    end
    
end
