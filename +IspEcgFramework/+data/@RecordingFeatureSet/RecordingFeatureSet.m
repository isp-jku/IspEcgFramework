classdef RecordingFeatureSet < handle
    %FEATURESET Summary of this class goes here
    %   Detailed explanation goes here
    
    % TODO: make beat, lead and recording features read only
    properties
        Tag string = string(0);
        LeadFeatures containers.Map = containers.Map();
        RecordingFeature
    end
    
    methods
        function processedFeatureSet = process(obj, processor)
            IspEcgFramework.util.Configuration.ValidationHelper.validateNonEmptyAndTypeOfArgument(processor, 'IspEcgFramework.extraction.Processor', 'processor', 'IspEcgFramework:extraction:Processor:invalidProcessorArgument');
            processedFeatureSet = processor.process(obj);
            if(empty(processedFeatureSet) || ~isa(processedFeatureSet, 'IspEcgFramework.extraction.FeatureSet'))
                throw(MException('IspEcgFramework:data:FeatureSet:invalidProcessorResult', sprintf('The processed value returned from a %s cannot be empty or of other type than IspEcgFramework.data.FeatureSet.', class(processor))));
            end
        end
    end
    
end