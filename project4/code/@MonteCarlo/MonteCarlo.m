classdef MonteCarlo < handle
    %MONTECARLO Localization algorithm
    
    properties
        p  % particles
        
        h_p
    end
    
    methods
        % Constructor
        function MC = MonteCarlo(n_p)
            p = zeros(3,n_p);
        end
        
        % 
        
        % Visualization methods
        function plot_particle(MC, varargin)
            
        end
        
    end
    
end

