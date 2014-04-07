classdef MDP < handle
    %MDP Markov Decision Process     
    properties
        im      % filtered original image
        f       % features space Fi
        l       % loss field
        policy  % example policy
        start
        goal
        type    % drive or walk
    end
    
    properties (Dependent = true, SetAccess = private)
        nr
        nc
    end
    
    methods
        % Constructor
        function obj = MDP(im, type)
            obj.im = im;
            obj.f = MDP.hsv_feature(obj.im);
            obj.type = type;
        end
        
        % Add policy
        function addPolicy(obj)
            [new_policy, click] = obj.drawPolicy();
            n = numel(new_policy);
            for i = 1:n
                obj.policy{end+1} = new_policy{i};
                obj.start(end+1,:) = click{i}(1,:);
                obj.goal(end+1,:) = click{i}(end,:);
            end
            fprintf('%d new %s policy added\n', n, obj.type);
        end
        
        function [policy, clicks] = drawPolicy(obj)
            policy = cell(0);
            clicks = cell(0);
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
                    plot(x, y, 'bo');
                    x = round(x);
                    y = round(y);
                    if size(click,1) > 0
                        [r,c] = getMapCellsFromRay(click(end,1), click(end,2), y, x);
                        plot(c, r, 'b.');
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
                        policy{k} = pos;
                        clicks{k} = click;
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
        function plot(obj, m)
            if nargin < 2,
                m = 1:numel(obj.policy);
            else
                m(m > numel(obj.policy)) = [];
            end
            m = unique(m);
            n = numel(m);
            imshow(obj.im);
            set(gca, 'Visible', 'On');
            title(sprintf('%d %s examples', n, obj.type))
            % Plot policies
            hold on
            for i = 1:numel(m)
                plot(obj.policy{m(i)}(:,2), obj.policy{m(i)}(:,1), 'b.');
                plot(obj.start(m(i),2), obj.start(m(i),1), 'o', 'MarkerFaceColor', 'g')
                plot(obj.goal(m(i),2), obj.goal(m(i),1), 'o', 'MarkerFaceColor', 'r')
            end
            hold off
        end
        
        % Generate loss field
        function l = genLossField(obj)
            for i = 1:numel(obj.policy)
                p = obj.policy{i};
                l = zeros(obj.nr, obj.nc);
                ind = sub2ind(size(l), p(:,1), p(:,2));
                l(ind) = 1;
                sigma = 5*sqrt(2);
                G = fspecial('gaussian', 8*ceil(sigma), sigma);
                l = imfilter(l, G);
                obj.l{i} = 1-imadjust(l, [0 0.85*max(l(:))], []);
            end
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
        f = lab_feature(im)
        f = hsv_feature(im)
    end
end
