classdef PoseNode
    %PoseNode
    properties (Constant)
        line_colors = lines(5);
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
                idx = ([obj.id] == ids(i));
                x_robot = [obj.x];
                y_robot = [obj.y];
                robot_color = obj(1).line_colors(ids(i),:);
                plot(h, x_robot(idx), y_robot(idx), ...
                    '-o', ...
                    'Color', robot_color, ...
                    'MarkerFaceColor', robot_color, ...
                    'LineWidth', 2)
                if inputs.show_orientation
                    % Not implemented yet
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
parser.addParamValue('showOrientation', false, @islogical);

% Parse input
parser.parse(varargin{:});

% Assign return values
h = parser.Results.axis_handle;
if isempty(h), h = gca; end
inputs.show_orientation = parser.Results.showOrientation;

end