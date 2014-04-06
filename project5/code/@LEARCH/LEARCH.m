classdef LEARCH < handle
    %LEARCH
    
    properties
        train_data
        test_data
        d
        w
    end
    
    methods
        % Constructor
        function obj = LEARCH(train_data, test_data)
            obj.train_data = train_data;
            obj.test_data = test_data;
            obj.d = size(obj.train_data(1).f, 3);
            obj.w = zeros(3,1);
        end
        
        % Train
        function train(obj)
            
        end
    end
    
end

