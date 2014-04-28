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
            for i = 1:numel(ids)
                % Pick poses for the current robot
                ind = ([obj.id] == ids(i));
                x_robot = [obj(ind).x];
                y_robot = [obj(ind).y];
                robot_color = PoseNode.colors(ids(i),:);
                plot(h, x_robot, y_robot, '-o', ...
                    'Color', robot_color, ...
                    'MarkerFaceColor', robot_color, ...
                    'MarkerEdgeColor', 'k', ...
                    'LineWidth', 1)
                
                if inputs.show_scan
                    xy_global = [obj(ind).gscan];
                    plot(h, xy_global(1,:), xy_global(2,:), '.', ...
                        'Color', robot_color, ...
                        'MarkerSize', 1);
                end
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
parser.CaseSensitive = true;
parser.addOptional('axis_handle', [], @ishghandle);
parser.addParamValue('ShowScan', false, @islogical);

% Parse input
parser.parse(varargin{:});

% Assign return values
h = parser.Results.axis_handle;
if isempty(h), h = gca; end
inputs.show_scan = parser.Results.ShowScan;

end