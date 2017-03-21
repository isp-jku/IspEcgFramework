classdef BeatPRVisitor < IspEcgFramework.extraction.MarkerVisitor
    %EcgBeatPRVisitor Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function feature = visit(obj, recording, lead, marker)
            if isa(marker, 'IspEcgFramework.data.BeatMarker') && ~isempty(lead)
                if isempty(marker.POn) || isempty(marker.RPeak)
                    feature = IspEcgFramework.Constants.NotAFeature;
                else
                    feature = marker.RPeak - marker.POn;
                end
            else
                feature = [];
            end
        end
    end
end