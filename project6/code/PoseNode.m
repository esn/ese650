%%%
%> @file PoseNode.m
%> @brief A class for node in a pose graph
%%%
classdef PoseNode < handle
    
    properties (Constant, Access = private)
        colors = lines(5);  %> Robot colors
    end
    
    properties
        id     %> Robot id
        pose   %> Pose of this pose node
        t      %> Unix time of this pose node
        color  %> Robot color
        gscan  %> Horizontal laser scan in global frame
        lscan  %> Horizontal laser scan in local frame
    end
    
    properties (Dependent = true)
        x    %> X coordinate of this node in global frame
        y    %> Y coordinate of this node in global frame
        yaw  %> Yaw angle of this node in global frame
        H    %> Matrix transform scan from local to global frame
    end
    
    methods
        %%%
        %> @brief Class constructor
        %> Instantiates an object of PoseNode
        %>
        %> @param packet a packet from log.mat
        %> @return instance of the PoseNode class
        %%%
        function obj = PoseNode(id, pose, t, gscan)
            obj.id    = id;
            obj.pose  = pose;
            obj.t     = t;
            obj.color = obj.colors(obj.id,:);
            obj.gscan = gscan;
            % Calculate scan in local frame
            R = [cos(obj.yaw) -sin(obj.yaw); sin(obj.yaw)  cos(obj.yaw)];
            obj.lscan = R' * bsxfun(@minus, obj.gscan, obj.pose(1:2));
            % Remove scan that is too far away
            range_ind = sum(obj.lscan.^2) < 12^2;
            obj.gscan = obj.gscan(:,range_ind);
            obj.lscan = obj.lscan(:,range_ind);
        end
        
        %%%
        %> @brief plot pose node with options
        %> Plot pose node in global frame, with options to show scan
        %>
        %> @param varargin optional: axis_handle, param: 'ShowScan', logical
        %%%
        function plot(obj, varargin)
            % Parse inputs
            [h, inputs] = parse_plot_inputs(obj, varargin{:});
            
            % Different robots have different colors
            ids = unique([obj.id]);
            for i_robot = 1:numel(ids)
                % Pick poses for the current robot
                ind = ([obj.id] == ids(i_robot));
                x_robot = [obj(ind).x];
                y_robot = [obj(ind).y];
                robot_color = PoseNode.colors(ids(i_robot),:);
                plot(h, x_robot, y_robot, '-o', ...
                    'Color', robot_color, ...
                    'MarkerFaceColor', robot_color, ...
                    'MarkerSize', 4, ...
                    'LineWidth', 1)
                
                if inputs.show_scan
                    pnodes = obj(ind);
                    for i_node = 1:numel(pnodes)
                        x_i = pnodes(i_node).pose;
                        T_i = v2t(x_i);
                        n_scan = size(pnodes(i_node).lscan,2);
                        xy_global = ...
                            T_i * [pnodes(i_node).lscan; ones(1,n_scan)];
                        % Update gscan or not?
                        %pnodes(i_node).gscan = xy_global(1:2,:);
                        plot(h, xy_global(1,:), xy_global(2,:), '.', ...
                            'Color', robot_color, ...
                            'MarkerSize', 1);
                    end
                end  % plot scan
                
            end  % for each robot
        end  % plot
        
        % Get methods
        function x = get.x(obj)
            x = obj.pose(1);
        end
        
        function y = get.y(obj)
            y = obj.pose(2);
        end
        
        function yaw = get.yaw(obj)
            yaw = obj.pose(3);
        end
        
        function H = get.H(obj)
            R = [cos(obj.yaw) -sin(obj.yaw); sin(obj.yaw)  cos(obj.yaw)];
            H = [R [obj.x; obj.y]; 0 0 1];
        end
    end  % methods
    
end  % classdef

%%%
%> @brief parse input for plot method
%> Plot pose node in global frame, with options to show scan
%>
%> @param varargin optional: axis_handle, param: 'showScan', logical
%%%
function [h, inputs] = parse_plot_inputs(~, varargin)
% Initialize input parser
parser = inputParser;
parser.addOptional('axis_handle', [], @ishghandle);
parser.addParamValue('ShowScan', false, @islogical);

% Parse input
parser.parse(varargin{:});

% Assign parsed inputs
h = parser.Results.axis_handle;
if isempty(h), h = gca; end
inputs.show_scan = parser.Results.ShowScan;

end