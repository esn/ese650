classdef MDP < handle
    %MDP Markov Decision Process 
    properties (Constant)
        walk_color = 'b';
        drive_color = 'r';
    end
    
    properties
        im
        f
        walk_policy   % [r c]
        drive_policy  % [r c]
    end
    
    properties (Dependent = true, SetAccess = private)
        nr
        nc
    end
    
    methods
        % Constructor
        function obj = MDP(im)
            obj.im = im;
            obj.f = MDP.rgb_feature(obj.im);
        end
        
        % Add policy
        function addDrivePolicy(obj)
            new_policy = obj.addPolicy(obj.drive_color);
            n = numel(new_policy);
            for i = 1:n
                obj.drive_policy{end+1} = new_policy{i};
            end
            fprintf('%d new drive policy added\n', n);
        end
        
        function addWalkPolicy(obj)
            new_policy = obj.addPolicy(obj.walk_color);
            n = numel(new_policy);
            for i = 1:n
                obj.walk_policy{end+1} = new_policy{i};
            end
            fprintf('%d new walk policy added\n', n);
        end
        
        function p = addPolicy(obj, color)
            p = [];
            k = 0;
            pos = zeros(0,2);   % store all the cells
            click = zeros(0,2); % store all the clicks
            finished = false;
            prev_button = 1;
            
            obj.plot();
            hold on
            while ~finished
                [x,y,button] = ginput(1);
                % add point to pos
                if button == 1
                    plot(x, y, 'Color', color, 'Marker', 'o');
                    x = round(x);
                    y = round(y);
                    if size(click,1) > 0
                        [r,c] = getMapCellsFromRay(click(end,1), click(end,2), y, x);
                        plot(c, r, [color, '.']);
                        n = numel(r);
                        pos(end+1:end+n,:) = [r c];
                    end
                    click(end+1,:) = [y x];
                elseif button == 3
                    % stop if right click twice
                    if prev_button == 3
                        finished = true;
                        break
                    end
                    % add to p if right click once
                    if size(click,1) > 1
                        k = k + 1;
                        p{k} = pos;
                        pos = zeros(0,2);
                        click = zeros(0,2);
                    end
                end
                prev_button = button;
            end
            hold off
            close
        end
        
        % Visualization methods
        function plot(obj)
            imshow(obj.im);
            set(gca, 'Visible', 'On');
            n_drive = numel(obj.drive_policy);
            n_walk = numel(obj.walk_policy);
            title(sprintf('%d drive example, %d walk example', n_drive, n_walk))
            % Plot policies
            hold on
            for i = 1:numel(obj.drive_policy)
                plot(obj.drive_policy{i}(:,2), obj.drive_policy{i}(:,1), ...
                    [obj.drive_color, '.']);
            end
            for i = 1:numel(obj.walk_policy)
                plot(obj.walk_policy{i}(:,2), obj.walk_policy{i}(:,1), ...
                    [obj.walk_color, '.']);
            end
            hold off
        end
        
        % Generate loss field
        function l = genLossField(obj, p)
            l = zeros(obj.nr, obj.nc);
            ind = sub2ind(size(l), p(:,1), p(:,2));
            l(ind) = 1;
            
            sigma = 5*sqrt(2);
            G = fspecial('gaussian', 8*ceil(sigma), sigma);
            l = imfilter(l, G);
            l = 1-imadjust(l, [0 0.85*max(l(:))], []);
        end
        
        % Get methods
        function nr = get.nr(obj)
            nr = size(obj.im,1);
        end
        
        function nc = get.nc(obj)
            nc = size(obj.im,2);
        end
    end
    
    methods (Static)
        f = rgb_feature(im)
    end
end
