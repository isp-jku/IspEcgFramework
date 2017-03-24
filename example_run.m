% ensure that the library is in the matlab path
clear; 
close all;
clc

%% read Physionet files
rootPath = fileparts(mfilename('fullpath'));
reader = IspEcgFramework.io.PhysionetFileReader();

reader.EcgkitPath = string([rootPath filesep 'workdir' filesep 'ecg-kit-0.1.6' filesep]);
reader.RecordingsPath = string([rootPath filesep 'workdir' filesep 'testrecordings' filesep ]);
reader.OutputPath = string([ rootPath filesep 'workdir' filesep 'results' filesep ]);
reader.TempPath = string([rootPath filesep 'workdir' filesep 'temp']);
data = reader.run();

%% filter/select files
recordingFilter = IspEcgFramework.filter.RecordingNameCriteria(string.empty(0,0), string('100'), true);
leadV5Filter = IspEcgFramework.filter.LeadNameCriteria(string.empty(0,0), string('V5'), false);
data.filter(recordingFilter, leadV5Filter, IspEcgFramework.filter.MarkerCriteria());

%% extract features
beatVisitor = IspEcgFramework.extraction.BeatPRVisitor();
prIntervals = data.extractFeature(IspEcgFramework.extraction.RecordingVisitor(), IspEcgFramework.extraction.LeadVisitor(), beatVisitor);