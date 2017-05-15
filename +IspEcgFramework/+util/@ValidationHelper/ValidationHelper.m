classdef (Abstract) ValidationHelper
    %EXCEPTIONHELPER Summary of this class goes here
    %   Detailed explanation goes here
    
    
    methods(Abstract, Access = public)
        obj = validateNonEmptyAndTypeOfArgument(obj, object, variableType, variableName, exceptionTag);
    end
    
end