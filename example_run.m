% ensure that the library is in the matlab path
clear; 
close all;
clc

%% read Physionet files
rootPath = fileparts(mfilename('fullpath'));
cachePath = [rootPath filesep 'workdir' filesep 'cache'];
cache = IspEcgFramework.io.FileCache(string(cachePath));
if (cache.exists(string('dummy')))
    data = cache.get(string('dummy'));
else
    reader = IspEcgFramework.io.PhysionetFileReader();
    reader.EcgkitPath = string([rootPath filesep 'workdir' filesep 'ecg-kit-0.1.6' filesep]);
    reader.RecordingsPath = string([rootPath filesep 'workdir' filesep 'testrecordings' filesep ]);
    reader.OutputPath = string([ rootPath filesep 'workdir' filesep 'results' filesep ]);
    reader.TempPath = string([rootPath filesep 'workdir' filesep 'temp']);
    data = reader.run();
    cache.put(string('dummy'), data);
end

%% filter/select files
recordingFilter = IspEcgFramework.filter.RecordingNameCriteria(string.empty(0,0), string('100'), true);
leadV5Filter = IspEcgFramework.filter.LeadNameCriteria(string.empty(0,0), string('V5'), false);
data.filter(recordingFilter, leadV5Filter, IspEcgFramework.filter.MarkerCriteria());

%% extract features
beatVisitor = IspEcgFramework.extraction.BeatPRVisitor();
prIntervalsFeatureSet = data.extractFeatureSet(IspEcgFramework.extraction.RecordingVisitor(), IspEcgFramework.extraction.LeadVisitor(), beatVisitor);

%% do further processing
pcaProcessor = IspEcgFramework.extraction.PCAProcessor();
pcaProcessor.process(prIntervalsFeatureSet);