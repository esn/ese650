classdef GraphSlam < handle
    %GRAPHSLAM
    
    properties
        pnode
        iter
        Omega
        xi
    end
    
    methods
        %
        % Constructor
        %
        function obj = GraphSlam(pnode, iter)
            obj.pnode = pnode;
            obj.iter  = iter;
        end
    end
    
end
