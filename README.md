# IspEcgFramework
IspEcgFramework is a Matlab package that contains some classes to process ECG signals.

## Installation
Extract the zip file and add it to the Matlab path with subdirectories. All classes are in the namespace `IspEcgFramework`.

## Example usage
```matlab
% ensure that the library is in the matlab path
clear all; close all;

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

%% Train and classify
```

## Notes
* This library is currently in an very early stage of development.
* This library uses features introduced in Matlab 2016b and will not work with older versions of Matlab.
[//]: # (* The version of the library is defined in `IspEcgFramework.Constants.Version`)

## Involuntary contributions
* The `IspEcgFramework.io.PhysionetFileReader` class uses feature provided by [ecg-kit](https://github.com/marianux/ecg-kit) which internally uses the [WFDB Toolbox](https://www.physionet.org/physiotools/matlab/wfdb-app-matlab/) from [PhysioNet](https://physionet.org/).
