classdef BeatMarker < IspEcgFramework.data.Marker
    %ECGWAVE instances contain all available data for a single ecg wave.
    
    properties
        % TODO - maybe they are not relative !! all times (sample number) are relative to the wave start
        POn int32; % P wave onset
        PPeak int32; % P wave peak
        POff int32; % P wave offset
        PTipo int32; % TODO: ask
        QrsOn int32; % QRS complex onset
        QrsFiducial int32; % QRS fiducial point, obtained from QRS detection
        QPeak int32; % Q wave peak
        RPeak int32; % R wave peak
        SPeak int32; % S wave peak
        QrsOff int32; % QRS complex offset
        TOn int32; % T wave onset
        TPeak int32; % T wave peak
        TPrima int32; % TODO: ask
        TOff int32; % T wave offset
        TTipo int32; % TODO: ask
        
        StartSample int32; % first sample in EcgRecording that belongs to this beat
        EndSample int32; % last sample in EcgRecording that belongs to this beat
        ClassifiedType int32 = 6; % set of EcgAnnotation annotations labeled by experts
        AnnotatedType int32 = 6; % unclassified basically means unannotated
    end
    
    methods
        % converts AAMI annotations to the simple types
        %         function obj = set.Type(obj, value)
        %             if EcgBeat.isBeatType(value)
        %                 obj.Type = EcgBeatType(value);
        %             else
        %                 % TODO: not set waring or a better approach in general
        %                 disp(['not converting ' value]);
        %             end
        %         end
        function startIndex = getStartIndex(obj)
            if ~isempty(obj.POn)
                startIndex = obj.POn;
                return;
            end
            if ~isempty(obj.PPeak)
                startIndex = obj.PPeak;
                return;
            end
            if ~isempty(obj.POff)
                startIndex = obj.POff;
                return;
            end
            if ~isempty(obj.QrsOn)
                startIndex = obj.QrsOn;
                return;
            end
            if ~isempty(obj.QPeak)
                startIndex = obj.QPeak;
                return;
            end
            if ~isempty(obj.RPeak)
                startIndex = obj.RPeak;
                return;
            end
            if ~isempty(obj.SPeak)
                startIndex = obj.SPeak;
                return;
            end
            if ~isempty(obj.QrsOff)
                startIndex = obj.QrsOff;
                return;
            end
            if ~isempty(obj.TOn)
                startIndex = obj.TOn;
                return;
            end
            if ~isempty(obj.TPeak)
                startIndex = obj.TPeak;
                return;
            end
            if ~isempty(obj.TOff)
                startIndex = obj.TOff;
                return;
            end
        end
        function endIndex = getEndIndex(obj)
            if ~isempty(obj.TOff)
                endIndex = obj.TOff;
                return;
            end
            if ~isempty(obj.TPeak)
                endIndex = obj.TPeak;
                return;
            end
            if ~isempty(obj.TOn)
                endIndex = obj.TOn;
                return;
            end
            if ~isempty(obj.QrsOff)
                endIndex = obj.QrsOff;
                return;
            end
            if ~isempty(obj.SPeak)
                endIndex = obj.SPeak;
                return;
            end
            if ~isempty(obj.RPeak)
                endIndex = obj.RPeak;
                return;
            end
            if ~isempty(obj.QPeak)
                endIndex = obj.QPeak;
                return;
            end
            if ~isempty(obj.QrsOn)
                endIndex = obj.QrsOn;
                return;
            end
            if ~isempty(obj.POff)
                endIndex = obj.POff;
                return;
            end
            if ~isempty(obj.PPeak)
                endIndex = obj.PPeak;
                return;
            end
            if ~isempty(obj.POn)
                endIndex = obj.POn;
                return;
            end
        end
        function isIndex = containsIndex(obj, index)
            startIndex = obj.getStartIndex();
            endIndex = obj.getEndIndex();
            if endIndex >= startIndex && startIndex <= index && endIndex >= index
                isIndex = 1;
            else
                isIndex = 0;
            end
        end
        
        function normalizeNaN(obj)
            default = IspEcgFramework.Constants.MakerPointNotSpecified;
            obj.POn = obj.normalizeNaNSingleProperty(obj.POn, default);
            obj.PPeak = obj.normalizeNaNSingleProperty(obj.PPeak, default);
            obj.POff = obj.normalizeNaNSingleProperty(obj.POff, default);
            obj.PTipo = obj.normalizeNaNSingleProperty(obj.PTipo, default);
            obj.QrsOn = obj.normalizeNaNSingleProperty(obj.QrsOn, default);
            obj.QrsFiducial = obj.normalizeNaNSingleProperty(obj.QrsFiducial, default);
            obj.QPeak = obj.normalizeNaNSingleProperty(obj.QPeak, default);
            obj.RPeak = obj.normalizeNaNSingleProperty(obj.RPeak, default);
            obj.SPeak = obj.normalizeNaNSingleProperty(obj.SPeak, default);
            obj.QrsOff = obj.normalizeNaNSingleProperty(obj.QrsOff, default);
            obj.TOn = obj.normalizeNaNSingleProperty(obj.TOn, default);
            obj.TPeak = obj.normalizeNaNSingleProperty(obj.TPeak, default);
            obj.TPrima = obj.normalizeNaNSingleProperty(obj.TPrima, default);
            obj.TOff = obj.normalizeNaNSingleProperty(obj.TOff, default);
            obj.TTipo = obj.normalizeNaNSingleProperty(obj.TTipo, default);
            
            obj.StartSample = obj.normalizeNaNSingleProperty(obj.StartSample, default);
            obj.EndSample = obj.normalizeNaNSingleProperty(obj.EndSample, default);
        end
    end
    
    methods(Static=true)
        function r = isRythmAnnotation(value)
            % TODO replace by non-deprecated function
            annotations = {'(AB', '(AFIB', '(AFL', '(B', '(BII', '(IVR', '(N', '(NOD', '(P', '(PREX', '(SBR', '(SVTA', '(T', '(VFL', '(VT'};
            r = ~(length(strmatch(value, annotations))==0);
        end
        
        function q = isSignalQualityAnnotation(value)
            annotations = {'qq', 'U', 'M', 'MISSB', 'P', 'PSE', 'T', 'TS'};
            q = ~(length(strmatch(value, annotations))==0);
        end
        
        function b = isBeatType(value)
            b = ~EcgBeat.isRythmAnnotation(value) && ~EcgBeat.isSignalQualityAnnotation(value);
        end
    end
    
    methods(Access = protected)
        function marker = copyElement(obj)
            marker = copyElement@matlab.mixin.Copyable(obj);
        end
    end
    
    methods (Access = private, Static=true)
        function normalized = normalizeNaNSingleProperty(property, default)
            if  isempty(property) || property == 0
                normalized = default;
            else
                normalized = property;
            end
        end
    end
    
end