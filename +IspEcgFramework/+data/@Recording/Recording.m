classdef Recording < matlab.mixin.SetGetExactNames & matlab.mixin.Copyable & matlab.mixin.CustomDisplay
    
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name string;   % name of the recording
        Samplerate int32; % samplerate in Hz
        Leads IspEcgFramework.data.Lead; % containing the raw samples of the ecg beat
        MultileadMarkers IspEcgFramework.data.Marker; % beats to which this recording is delineated to
    end
    
    methods (Access = public)
        function addLead(obj, lead)
            if length(lead)~=1 || ~isa(lead, 'IspEcgFramework.data.Lead')
                throw(MException('IspEcgFramework:data:Data:addLead:invalidLead', 'lead argument is null or not an instance of Lead'));
            end
            obj.Leads = [obj.Leads lead];
        end
        
        function addMultileadMarker(obj, marker)
            if length(marker)~=1 || ~isa(marker, 'IspEcgFramework.data.Marker')
                throw(MException('IspEcgFramework:data:Data:addMultileadMarker:invalidMarker', 'marker argument is null or not an instance of Marker'));
            end
            obj.MultileadMarkers = [obj.MultileadMarkers marker];
        end
        
        function featureVector = extractFeature(obj, recordingVisitor, leadVisitor, markerVisitor)
            if length(recordingVisitor)~=1 || ~isa(recordingVisitor, 'IspEcgFramework.extraction.RecordingVisitor')
                throw(MException('IspEcgFramework:data:Data:extractFeature:invalidRecordingVisitor', 'recordingVisitor argument is not an instance of RecordingVisitor'));
            end
            if length(leadVisitor)~=1 || ~isa(leadVisitor, 'IspEcgFramework.extraction.LeadVisitor')
                throw(MException('IspEcgFramework:data:Data:extractFeature:invalidLeadVisitor', 'leadVisitor argument is not an instance of LeadVisitor'));
            end
            if length(markerVisitor)~=1 || ~isa(markerVisitor, 'IspEcgFramework.extraction.MarkerVisitor')
                throw(MException('IspEcgFramework:data:Data:extractFeature:invalidMarkerVisitor', 'markerVisitor argument is not an instance of MarkerVisitor'));
            end
            
            featureVector = recordingVisitor.visit(obj);
            for i = 1:length(obj.Leads)
                featureVector = [featureVector obj.Leads(i).extractFeature(obj, leadVisitor, markerVisitor)];
            end
        end
    end
    
    methods(Access = protected)
        function recording = copyElement(obj)
            recording = copyElement@matlab.mixin.Copyable(obj);
            recording.Leads = obj.Leads.copy();
            recording.MultileadMarkers = obj.MultileadMarkers.copy();
        end
%         function displayScalarObject(obj)
%             disp(['Recording ', obj.Name]);
%         end
    end
end