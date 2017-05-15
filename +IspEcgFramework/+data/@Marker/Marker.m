classdef Marker < handle & matlab.mixin.SetGetExactNames & matlab.mixin.Heterogeneous & matlab.mixin.Copyable
    %MARKER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function featureSetEntry = extractFeature(obj, recording, lead, markerVisitor)
            if length(recording)~=1 || ~isa(recording, 'IspEcgFramework.data.Recording')
                throw(MException('IspEcgFramework:data:Marker:extractFeature:invalidRecording', 'recording argument is not an instance of Recording'));
            end
            if length(lead)~=1 || ~isa(lead, 'IspEcgFramework.data.Lead')
                throw(MException('IspEcgFramework:data:Marker:extractFeature:invalidLead', 'lead argument is not an instance of Lead'));
            end
            if length(markerVisitor)~=1 || ~isa(markerVisitor, 'IspEcgFramework.extraction.MarkerVisitor')
                throw(MException('IspEcgFramework:data:Marker:extractFeature:invalidMarkerVisitor', 'markerVisitor argument is not an instance of MarkerVisitor'));
            end
            
            featureSetEntry = markerVisitor.visit(recording, lead, obj);
        end
    end
    
    properties
        % Recording IspEcgFramework.data.Recording; % refereences the Recording the beat belongs to
        % Lead IspEcgFramework.data.Lead % references the Lead the beat belongs to
    end
    
    %     methods (Static, Sealed, Access = protected)
    %        function defaultObject = getDefaultScalarElement
    %            defaultObject = IspEcgFramework.BeatMarker; % maybe create a dummy marker class that does nothing
    %        end
    %     end
    
end