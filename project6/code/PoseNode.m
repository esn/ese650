classdef PoseNode < handle
    %PoseNode
    properties (Constant)
        line_colors = lines(5);
        scan_colors = 'bgrcm';
    end
    
    properties
        x
        y
        yaw
        id
        hlidar
        vlidar
    end
    
    methods
        %
        % Constructor
        %
        function obj = PoseNode(packet)
            obj.x   = packet.pose.x;
            obj.y   = packet.pose.y;
            obj.yaw = packet.pose.yaw;
            obj.id  = packet.id;
            obj.hlidar = packet.hlidar;
            obj.vlidar = packet.vlidar;
        end
        
        %
        % plot
        % obj.plot()
        % obj.plot(axis_handle)
        % obj.plot(axis_handle, 'showOrientation', true)
        %
        function plot(obj, varargin)
            % Parse inputs
            [h, inputs] = parse_plot_inputs(obj, varargin{:});
            
            % Different robots have different colors
            ids = unique([obj.id]);
            for i = 1:numel(ids)
                was_held = ishold;
                if ~was_held, hold('on'); end
                
                % Pick poses for the current robot
                ind = ([obj.id] == ids(i));
                x_robot = [obj.x];
                y_robot = [obj.y];
                robot_color = obj(1).line_colors(ids(i),:);
                plot(h, x_robot(ind), y_robot(ind), ...
                    '-o', ...
                    'Color', robot_color, ...
                    'MarkerFaceColor', robot_color, ...
                    'MarkerEdgeColor', 'k', ...
                    'LineWidth', 1)
                
                if inputs.show_yaw
                    % Not implemented yet
                end
                
                if inputs.show_scan
                    nodes = obj(ind);
                    for i_node = 1:numel(nodes)
                        curr_node = nodes(i_node);
                        x_scan = curr_node.hlidar.xs;
                        y_scan = curr_node.hlidar.ys;
                        plot(x_scan, y_scan, '.', ...
                            'Color', obj(1).scan_colors(curr_node.id), ...
                            'MarkerSize', 0.5);
                    end
                end
            end
        end
    end
end


%--------------------------------------------------------------------------
% Local functions
%--------------------------------------------------------------------------
function [h, inputs] = parse_plot_inputs(~, varargin)
% PARSE_PLOT_INPUTS

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