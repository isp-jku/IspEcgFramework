classdef PCAProcessor < IspEcgFramework.extraction.Processor
    % PCAProcessor Calculate lead wise pca
    
    properties
%         Description = string('Principal Component Analysis');
%         NumberOfComponents = 3;
    end
    
    methods
        function dataFeatureSet = process(obj, featureSet)
            dataFeatureSet = IspEcgFramework.data.DataFeatureSet();
            recordingKeys = featureSet.RecordingFeatures.keys;
            for i = 1:length(recordingKeys)
                recordingFeatureSet = featureSet.RecordingFeatures(char(recordingKeys(i)));
                newRecordingFeatureSet = IspEcgFramework.data.RecordingFeatureSet();
                leadKeys = recordingFeatureSet.LeadFeatures.keys;
                for j = 1:length(leadKeys)
                    leadFeatureSet = recordingFeatureSet.LeadFeatures(char(leadKeys(j)));
                    newLeadFeatureSet = IspEcgFramework.data.LeadFeatureSet();
                    newRecordingFeatureSet.LeadFeatures(char(leadKeys(j))) = newLeadFeatureSet;
                    markerKeys = leadFeatureSet.MarkerFeatures.keys;
                    pcaDataset = []; % TODO maybe preallocate for performance
                    for k = 1:length(markerKeys)
                        pcaDataset = [pcaDataset; leadFeatureSet.MarkerFeatures(char(markerKeys(k)))];
                    end
                    [coeff, score, latent] = pca(double(pcaDataset)); % coeff = base, score = weight, latent = eigenvalues
                    newLeadFeatureSet.LeadFeature = struct();
                    newLeadFeatureSet.LeadFeature.coeff = coeff;
                    newLeadFeatureSet.LeadFeature.latent = latent;
                    for k = 1:length(markerKeys) % should have same length as score
                        newLeadFeatureSet.MarkerFeatures(char(markerKeys(k))) = score(k,:);
                    end
                end
            end
        end
    end
    
end