classdef GMM < handle
    %GMM
    
    properties
        n_cluster
        color
        cspace
        model
    end
    
    methods
        % Constructor
        function obj = GMM(n_cluster, color, cspace)
            obj.n_cluster = n_cluster;
            obj.color = color;
            obj.cspace = cspace;
        end
        
        % train
        function train(obj, im, cspace)
            % Convert to desired colorspace
            im_cs = trans_cs(im, cspace);
            X = [];
            for i = 1:numel(im)
                bw = roipoly(im{i});
                pixels = im_cs{i}(bw, :);
                pixels = reshape(pixels, size(pixels,1)*size(pixels,2), []);
                X = [X; pixels];
                keyboard
            end
            X = double(X);
            options = statset('Display', 'final');
            obj.model = gmdistribution.fit(X, obj.n_cluster, ...
                'Replicates', 3, 'SharedCov', false, 'Options', options); 
        end
        
        % test
        function test(obj, im)
            im_cs = trans_cs(im, obj.cspace);
            for i = 1:numel(im)
                [nr,nc,~] = size(im_cs{i});
                X = reshape(im_cs{i}, nr*nc, []);
                X = double(X);
                [~,~,P] = obj.model.cluster(X);
                P = P * obj.model.PComponents(:);
                P = reshape(P, nr, nc);
                figure()
                subplot(1,2,1)
                imshow(im{i});
                subplot(1,2,2)
                imagesc(P);
                axis image;
            end
        end
    end
    
    methods (Static)
        
    end
    
end

