classdef DefaultValidationHelper < IspEcgFramework.util.ValidationHelper
    %DEFAULTVALIDATIONHELPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = protected)
        NonEmptyAndTypeOfArgumentMessage = '%s argument is empty or not an instance of %s';
    end
    
    methods (Access = public)
        function obj = validateNonEmptyAndTypeOfArgument(obj, object, variableType, variableName, exceptionTag)
            if(isempty(object) || ~isa(object, variableType))
                throw(MException(exceptionTag, sprintf(obj.NonEmptyAndTypeOfArgumentMessage, variableName, variableType)));
            end
        end
    end
    
end