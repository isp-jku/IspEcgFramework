classdef MarkerVisitor < handle & matlab.mixin.SetGetExactNames
    %ECGVISITOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function feature = visit(obj, recording, lead, marker)
            feature = [];
        end
    end
    
end