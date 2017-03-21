classdef Lead < handle & matlab.mixin.SetGetExactNames & matlab.mixin.Copyable
    %Lead Represents a single ecg lead
    
    properties
        Name string;     % name of the recording
        Samples double;   % containing the raw samples of the ecg beat; in Volts and compensated offset
        AdcResolution int32; % number of adc bits
        AdcGain int32; % adc gain settings
        Markers IspEcgFramework.data.Marker; % list of annotation markers. Please do only read as it may be protected in near future.
    end
    
    properties (SetAccess = protected)
        
    end
    
    methods (Access = public)
        % add a Marker to the lead
        function addMarker(obj, marker)
            if isempty(marker) || ~isa(marker, 'IspEcgFramework.data.Marker')
                throw(MException('IspEcgFramework:data:Lead:addMarker:invalidMarker', 'marker argument is null or not an instance of Marker'));
            end
            obj.Markers = [obj.Markers marker];
        end
        
        function featureVector = extractFeature(obj, recording, leadVisitor, markerVisitor)
            if length(recording)~=1 || ~isa(recording, 'IspEcgFramework.data.Recording')
                throw(MException('IspEcgFramework:data:Lead:extractFeature:invalidRecordingVisitor', 'recording argument is not an instance of Recording'));
            end
            if length(leadVisitor)~=1 || ~isa(leadVisitor, 'IspEcgFramework.extraction.LeadVisitor')
                throw(MException('IspEcgFramework:data:Lead:extractFeature:invalidLeadVisitor', 'leadVisitor argument is not an instance of LeadVisitor'));
            end
            if length(markerVisitor)~=1 || ~isa(markerVisitor, 'IspEcgFramework.extraction.MarkerVisitor')
                throw(MException('IspEcgFramework:data:Lead:extractFeature:invalidMarkerVisitor', 'markerVisitor argument is not an instance of MarkerVisitor'));
            end
            
            featureVector = leadVisitor.visit(recording, obj);
            for i = 1:length(obj.Markers)
                featureVector = [featureVector obj.Markers(i).extractFeature(recording, obj, markerVisitor)];
            end
        end
    end
    
    methods(Access = protected)
        function lead = copyElement(obj)
            lead = copyElement@matlab.mixin.Copyable(obj);
            lead.Markers = obj.Markers.copy();
        end
    end
    
    % TODO: Implement later and remove SetAccess=protected
    %     methods
    %         function set.Beats(obj, beats)
    %             throw(MException('ToDo', 'NotImplementedException');
    %         end
    %     end
    
end