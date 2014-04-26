%%%
%> @file PoseNode.m
%> @brief A class for node in a pose graph
%%%
classdef PoseNode < handle
    
    properties (Constant, Access = private)
        %> Robot colors
        colors = lines(5);
    end
    
    properties
        %> Pose of this pose node
        pose
        %> Robot id
        id
        %> Robot color
        color
        %> Horizontal laser scan in global frame
        gscan
        %> Horizontal laser scan in local frame
        lscan
    end
    
    properties (Dependent = true)
        %> X coordinate of this node in global frame
        x
        %> Y coordinate of this node in global frame
        y
        %> Yaw angle of this node in global frame
        yaw
        %> Matrix transform scan from local to global frame
        H
    end
    
    methods
        %%%
        %> @brief Class constructor
        %> Instantiates an object of PoseNode
        %>
        %> @param packet a packet from log.mat
        %> @return instance of the PoseNode class
        %%%
        function obj = PoseNode(packet)
            obj.pose  = [packet.pose.x; packet.pose.y; packet.pose.yaw];
            obj.id    = packet.id;
            obj.color = obj.colors(obj.id,:);
            obj.gscan = double([packet.hlidar.xs'; packet.hlidar.ys']);
            % Calculate scan in local frame
            R = [cos(obj.yaw) -sin(obj.yaw); sin(obj.yaw)  cos(obj.yaw)];
            obj.lscan = R' * bsxfun(@minus, obj.gscan, obj.pose(1:2));
        end
        
        %%%
        %> @brief plot pose node with options
        %> Plot pose node in global frame, with options to show scan
        %>
        %> @param varargin optional: axis_handle, param: 'showScan', logical
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
                
                if inputs.show_yaw
                    % Not implemented yet
                end
                
                if inputs.show_scan
                    xy_global = [obj(ind).gscan];
                    plot(h, xy_global(1,:), xy_global(2,:), '.', ...
                        'Color', robot_color, ...
                        'MarkerSize', 0.5);
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
    
end

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
parser.addParamValue('showYaw', false, @islogical);
parser.addParamValue('showScan', false, @islogical);

% Parse input
parser.parse(varargin{:});

% Assign return values
h = parser.Results.axis_handle;
if isempty(h), h = gca; end
inputs.show_yaw = parser.Results.showYaw;
inputs.show_scan = parser.Results.showScan;

end