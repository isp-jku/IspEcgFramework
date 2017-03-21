classdef BeatType < handle
    %ECGBEATTYPE Summary of this class goes here
    
    enumeration
        Normal, % beats originating from sinus node
        Supraventricular, % supraventricular ectopic
        Ventricular, % ventricular ectopic
        Fusion, % fusion of normal and ectopic
        Other, % some other type
        Unusable, % labeled as unusable (signal loss or extreme noise)
        Unclassified;
    end
    
    methods (Static)
        function obj = getByAnnotationCharacter(val)
            % TODO: check if val is a String
            if strcmp(val, '.') || strcmp(val, 'N')
                obj = BeatType.Normal;
            elseif strcmp(val, 'S')
                obj = BeatType.Supraventricular;
            elseif strcmp(val, 'V')
                obj = BeatType.Ventricular;
            elseif strcmp(val, 'F')
                obj = BeatType.Fusion;
            else
                obj = BeatType.Other;
            end
        end
        
        function enumNumber = getByAnnotationCharacterToNumber(val)
            % TODO: check if val is a String
            if strcmp(val, '.') || strcmp(val, 'N')
                enumNumber = 1; % Normal
            elseif strcmp(val, 'S')
                enumNumber = 2; % Supraventricular
            elseif strcmp(val, 'V')
                enumNumber = 3; % Ventricular
            elseif strcmp(val, 'F')
                enumNumber = 4; % Fusion
            elseif strcmp(val, 'U')
                enumNumber = 6;
            else
                enumNumber = 5; % Other
            end
        end
        
        function beatAnnotation = isBeatAnnotation(val)
            if strcmp(val, 'N') || strcmp(val, 'S') || strcmp(val, 'V') || strcmp(val, 'F') ||strcmp(val, 'Q')
                beatAnnotation = 1;
            else
                beatAnnotation = 0;
            end
        end
    end
end