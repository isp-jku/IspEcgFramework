classdef QrsMarker < handle & matlab.mixin.SetGetExactNames & IspEcgFramework.data.Marker
    %QRSMARKER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Qrs int32; % index of the
    end
    
    methods
    end
    
    methods(Access = protected)
        function marker = copyElement(obj)
            marker = copyElement@matlab.mixin.Copyable(obj);
        end
    end
    
end