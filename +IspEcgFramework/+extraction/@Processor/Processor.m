classdef (Abstract) Processor < handle
    %PROCESSOR Summary of this class goes here
    %   Detailed explanation goes here
    
%     properties(Access = protected)
%         Description = string(0);
%     end
    
    methods (Abstract)
        dataFeatureSet = process(obj, featureSet);
%         function description = describe(obj)
%             description = obj.Description;
%         end
    end
    
end