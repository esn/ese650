classdef PoseNode
    %PoseNode
    properties (Constant)
        line_colors = lines(5);
    end
    
    properties
        x
        y
        yaw
        robot_id
    end
    
    methods
        %
        % Constructor
        %
        function obj = PoseNode(x, y, yaw, robot_id)
            obj.x = x;
            obj.y = y;
            obj.yaw = yaw;
            obj.robot_id = robot_id;
        end
        
        %
        % plot
        %
        function plot(obj, varargin)
            % Parse inputs
            [h, inputs] = parse_plot_inputs(obj, varargin{:});
            
            % Different robots have different colors
            robot_ids = unique([obj.robot_id]);
            for i = 1:numel(robot_ids)
                was_held = ishold;
                if ~was_held, hold('on'); end
                idx = ([obj.robot_id] == robot_ids(i));
                x_robot = [obj.x];
                y_robot = [obj.y];
                plot(h, x_robot(idx), y_robot(idx), '-o', ...
                    'Color', obj(1).line_colors(robot_ids(i),:), ...
                    'LineWidth', 2)
                if inputs.show_orientation
                    % Not implemented
                end
            end
        end
    end
end


%--------------------------------------------------------------------------
function [h, inputs] = parse_plot_inputs(~, varargin)
% PARSE_PLOT_INPUTS

% Initialize input parser
parser = inputParser;
parser.CaseSensitive = true;
parser.addOptional('axis_handle', [], @ishghandle);
parser.addParamValue('showOrientation', false, @islogical);

% Parse input
parser.parse(varargin{:});

% Assign return values
h = parser.Results.axis_handle;
if isempty(h), h = gca; end
inputs.show_orientation = parser.Results.showOrientation;
end