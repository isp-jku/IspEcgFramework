classdef Data < handle & matlab.mixin.Copyable
    %Data Contains data to be analyzed
    %   Data is basically a list of Recordings
    
    properties
        Recordings IspEcgFramework.data.Recording;
    end
    
    methods (Access = public)
        
        function obj = Data()
        end
        
        function addRecording(obj, recording)
            if isempty(recording) || ~isa(recording, 'IspEcgFramework.data.Recording')
                throw(MException('IspEcgFramework:data:Data:addRecording:invalidRecording', 'recording argument is empty or not an instance of Recording'));
            end
            obj.Recordings = [obj.Recordings recording];
        end
        
        function filter(obj, recordingCriteria, leadCriteria, markerCriteria)
            % check if arguments are of correct type
            if nargin >= 1
                if length(recordingCriteria)~=1 || ~isa(recordingCriteria, 'IspEcgFramework.filter.RecordingCriteria')
                    throw(MException('IspEcgFramework:Data:filter:invalidRecordingCriteria', 'recordingCriterias argument is not an instance of RecordingCriteria'));
                end
            end
            if nargin >= 2
                if length(leadCriteria)~=1 || ~isa(leadCriteria, 'IspEcgFramework.filter.LeadCriteria')
                    throw(MException('IspEcgFramework:Data:filter:invalidLeadCriteria', 'leadCriteria argument is not an instance of LeadCriteria'));
                end
            end
            if nargin == 3
                if ~isempty(markerCriteria) || ~isa(markerCriteria, 'IspEcgFramework.filter.MarkerCriteria')
                    throw(MException('IspEcgFramework:Data:filter:invalidMarkerCriteria', 'markerCriteria argument is not an instance of MarkerCriteria'));
                end
            end
            % apply filters. start with recordingFilter then leadFilter and
            if nargin >= 1
                i = 1;
                while i <= length(obj.Recordings)
                    if recordingCriteria.meetCriteria(obj.Recordings(i))
                        % recording is not sorted out --> filter leads
                        if nargin >= 2
                            j = 1;
                            while j<=length(obj.Recordings(i).Leads)
                                if leadCriteria.meetCriteria(obj.Recordings(i), obj.Recordings(i).Leads(j))
                                    % lead is not sorted out --> filter markers
                                    if nargin == 3
                                        k = 1;
                                        while k<=length(obj.Recordings(i).Leads(j).Markers)
                                            if markerCriteria.meetCriteria(obj.Recordings(i), obj.Recordings(i).Leads(j), obj.Recordings(i).Leads(j).Markers(k))
                                                k = k + 1;
                                            else
                                                obj.Recordings(i).Leads(j).Markers(k) = [];
                                            end
                                        end
                                    end
                                    j = j+1;
                                else
                                    obj.Recordings(i).Leads(j) = [];
                                end
                            end
                        end
                        i = i+1;
                    else
                        obj.Recordings(i) = [];
                    end
                end
            end
        end
        
        function featureVector = extractFeature(obj, recordingVisitor, leadVisitor, markerVisitor)
            % check if arguments are of correct type
            if length(recordingVisitor)~=1 || ~isa(recordingVisitor, 'IspEcgFramework.extraction.RecordingVisitor')
                throw(MException('IspEcgFramework:Data:filter:invalidRecordingCriteria', 'recordingCriterias argument is not an instance of RecordingCriteria'));
            end
            if length(leadVisitor)~=1 || ~isa(leadVisitor, 'IspEcgFramework.extraction.LeadVisitor')
                throw(MException('IspEcgFramework:Data:filter:invalidLeadCriteria', 'leadCriteria argument is not an instance of LeadCriteria'));
            end
            if length(markerVisitor)~=1 || ~isa(markerVisitor, 'IspEcgFramework.extraction.MarkerVisitor')
                throw(MException('IspEcgFramework:Data:filter:invalidMarkerCriteria', 'markerCriteria argument is not an instance of MarkerCriteria'));
            end
            
            featureVector = [];
            for i = 1:length(obj.Recordings)
                featureVector = [featureVector obj.Recordings(i).extractFeature(recordingVisitor, leadVisitor, markerVisitor)];
            end
        end
    end
    
    
    
    methods(Access = protected)
        function data = copyElement(obj)
            data = copyElement@matlab.mixin.Copyable(obj);
            data.Recordings = obj.Recordings.copy();
        end
    end
    
    methods (Access = private)
        
    end
end