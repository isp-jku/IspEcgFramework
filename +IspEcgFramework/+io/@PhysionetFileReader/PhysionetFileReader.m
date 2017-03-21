classdef PhysionetFileReader
    %PHYSIONETCONVERTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        EcgkitPath string;
        RecordingsPath string;
        OutputPath string;
        TempPath string;
    end
    
    methods
        function data = run(obj)
            
            %% Default arguments
            recordingsPath = char(obj.RecordingsPath);
            outputPath = char(obj.OutputPath);
            tempPath = char(obj.TempPath);
            
            pidString = '1/1';
            userString = '';
            
            %% Add ECG-kit to path
            ecgkitRootPath = char(obj.EcgkitPath);
            
            %path related constants.
            ecgkitDefaulPaths = { ...
                [ ecgkitRootPath ';' ]; ...
                [ ecgkitRootPath 'help' filesep ';' ]; ...
                [ ecgkitRootPath 'common' filesep ';' ]; ...
                [ ecgkitRootPath 'common' filesep 'a2hbc' filesep ';' ]; ...
                [ ecgkitRootPath 'common' filesep 'a2hbc'  filesep 'scripts' filesep ';' ]; ...
                [ ecgkitRootPath 'common' filesep 'export_fig' filesep ';' ]; ...
                [ ecgkitRootPath 'common' filesep 'wavedet' filesep ';' ]; ...
                [ ecgkitRootPath 'common' filesep 'plot2svg' filesep ';' ]; ...
                [ ecgkitRootPath 'common' filesep 'ppg' filesep ';' ]; ...
                [ ecgkitRootPath 'common' filesep 'prtools' filesep ';' ]; ...
                [ ecgkitRootPath 'common' filesep 'prtools_addins' filesep ';' ]; ...
                [ ecgkitRootPath 'common' filesep 'bin' filesep ';' ]; ...
                [ ecgkitRootPath 'common' filesep 'kur' filesep ';' ]; ...
                [ ecgkitRootPath 'common' filesep 'LIBRA' filesep ';' ]; ...
                };
            
            cellfun(@(a)(addpath(a)), ecgkitDefaulPaths);
            
            %% Start
            filenames = dir(recordingsPath);
            recordingNames = {filenames(:).name};
            [~,recordingNames] = cellfun(@(a)(fileparts(a)), recordingNames, 'UniformOutput', false);
            recordingNames = unique(recordingNames);
            recordingNames = setdiff(recordingNames, {'' '.' '..' 'results' 'condor' });
            numberOfRecordings = length(recordingNames);
            
            %% QRS automatic detection
            
            % go through all files
            
            ECG_all_wrappers = [];
            jj = 1;
            
            for ii = 1:numberOfRecordings
                
                recordingFilename = [recordingsPath recordingNames{ii}];
                
                ECGt_QRSd = ECGtask_QRS_detection();
                ECGt_QRSd.detectors = 'wavedet'; % Wavedet algorithm based on
                ECGt_QRSd.only_ECG_leads = true;    % Identify ECG signals based on their header description.
                
                ECG_w = ECGwrapper( 'recording_name', recordingFilename, ...
                    'this_pid', pidString, ...
                    'tmp_path', tempPath, ...
                    'output_path', outputPath, ...
                    'ECGtaskHandle', ECGt_QRSd);
                
                % you can individualize each experiment with an external string
                ECG_w.user_string = userString;
                
                try
                    % process the task
                    ECG_w.Run;
                    
                    % collect object if were recognized as ECG recordings.
                    if( jj == 1)
                        ECG_all_wrappers = ECG_w;
                    else
                        ECG_all_wrappers(jj) = ECG_w;
                    end
                    jj = jj + 1;
                    
                catch MException
                    
                    if( strfind(MException.identifier, 'ECGwrapper:ArgCheck:InvalidFormat') )
                        disp_string_framed('*Red', sprintf( 'Could not guess the format of %s', ECG_w.recording_name) );
                    else
                        % report just in case
                        report = getReport(MException);
                        fprintf(2, '\n%s\n', report);
                    end
                end
                
            end
            
            % recognized recordings
            numberOfRecordings = length(ECG_all_wrappers);
            
            % at the end, report problems if happened.
            for ii = 1:numberOfRecordings
                ECG_all_wrappers(ii).ReportErrors;
            end
            
            % at the end, report problems if happened.
            for ii = 1:numberOfRecordings
                ECG_all_wrappers(ii).ReportErrors;
            end
            
            %% ECG automatic delineation
            for ii = 1:numberOfRecordings
                
                % this is to use previous cached results as starting point
                cached_filenames = ECG_all_wrappers(ii).GetCahchedFileName('QRS_corrector');
                
                % set the delineator task name and run again.
                ECG_all_wrappers(ii).ECGtaskHandle = 'ECG_delineation';
                
                % if corrected QRS detections are not available, wavedet
                % performs automatic QRS detection.
                if( ~isempty(cached_filenames) )
                    % this is to use previous result from the automatic QRS
                    % detection
                    ECG_all_wrappers(ii).ECGtaskHandle.payload = load(cached_filenames{1});
                    
                end
                
                ECG_all_wrappers(ii).ECGtaskHandle.delineators = {'wavedet' 'user:my_ecg_delineation'};
                
                % process the task
                ECG_all_wrappers(ii).Run;
                disp('run');
                
            end
            
            % at the end, report problems if happened.
            for ii = 1:numberOfRecordings
                ECG_all_wrappers(ii).ReportErrors;
            end
            
            % serialize ECGWrapper object to a file for later inspection
            data = IspEcgFramework.data.Data();
            workerResults = IspEcgFramework.data.Recording.empty(0, 4);
            
            % parfor
            for ii = 1:numberOfRecordings
                ecgWrapper = ECG_all_wrappers(ii);
                ecgWrapperPath = [ecgWrapper.output_path ecgWrapper.ECG_header.recname '_combined.mat'];
                delineationStruct = load([ecgWrapper.output_path ecgWrapper.ECG_header.recname '_ECG_delineation.mat']);
                qrsStruct = load([ecgWrapper.output_path ecgWrapper.ECG_header.recname '_QRS_detection.mat']);
                
                recording = IspEcgFramework.data.Recording();
                recording.Name = string(ecgWrapper.ECG_header.recname);
                leads = IspEcgFramework.data.Lead.empty(ecgWrapper.ECG_header.nsig,0);
                % iterate over leads
                for jj = 1:ecgWrapper.ECG_header.nsig
                    leads(jj) = IspEcgFramework.data.Lead();
                    leads(jj).Name = strtrim(string(ecgWrapper.ECG_header.desc(jj,:)));
                    % assuming unit of samples is mV --> convert to V
                    % TODO: read value
                    allSamples = ecgWrapper.read_signal(jj, ecgWrapper.ECG_header.nsamp);
                    leads(jj).Samples = allSamples(:,jj)./1000 - ecgWrapper.ECG_header.adczero(jj);
                    if isfield(ecgWrapper.ECG_header, 'adcres')
                        leads(jj).AdcResolution = ecgWrapper.ECG_header.adcres(jj);
                    end
                    if isfield(ecgWrapper.ECG_header, 'gain')
                        leads(jj).AdcGain = ecgWrapper.ECG_header.gain(jj);
                    end
                    % TODO: check if this fields exist
                    %leads(jj).AdcResolution = ecgWrapper.ECG_header.adcres(jj);
                    %leads(jj).AdcGain = ecgWrapper.ECG_header.gain(jj);
                    leadQrsPoints = int32(qrsStruct.(char(strcat('wavedet_', leads(jj).Name))).time);
                    for i=1:length(leadQrsPoints)
                        qrsPoint = IspEcgFramework.data.QrsMarker();
                        qrsPoint.Qrs = leadQrsPoints(i);
                        % qrsPoint.Lead = leads(jj);
                        % qrsPoint.Recording = recording;
                        leads(jj).addMarker(qrsPoint);
                    end
                    
                    numberOfDetectedBeats = length(delineationStruct.wavedet.(char(leads(jj).Name)).Pon);
                    detectedBeats = IspEcgFramework.data.BeatMarker.empty(numberOfDetectedBeats, 0);
                    for kk = 1:numberOfDetectedBeats
                        detectedBeats(kk) = IspEcgFramework.data.BeatMarker();
                        detectedBeats(kk).POn = delineationStruct.wavedet.(char(leads(jj).Name)).Pon(kk);
                        detectedBeats(kk).PPeak = delineationStruct.wavedet.(char(leads(jj).Name)).P(kk);
                        detectedBeats(kk).POff = delineationStruct.wavedet.(char(leads(jj).Name)).Poff(kk);
                        detectedBeats(kk).QrsFiducial = delineationStruct.wavedet.(char(leads(jj).Name)).qrs(kk);
                        detectedBeats(kk).QrsOn = delineationStruct.wavedet.(char(leads(jj).Name)).QRSon(kk);
                        detectedBeats(kk).QPeak = delineationStruct.wavedet.(char(leads(jj).Name)).Q(kk);
                        detectedBeats(kk).RPeak = delineationStruct.wavedet.(char(leads(jj).Name)).R(kk);
                        detectedBeats(kk).SPeak = delineationStruct.wavedet.(char(leads(jj).Name)).S(kk);
                        detectedBeats(kk).QrsOff = delineationStruct.wavedet.(char(leads(jj).Name)).QRSoff(kk);
                        detectedBeats(kk).TOn = delineationStruct.wavedet.(char(leads(jj).Name)).Ton(kk);
                        detectedBeats(kk).TPeak = delineationStruct.wavedet.(char(leads(jj).Name)).T(kk);
                        detectedBeats(kk).TPrima = delineationStruct.wavedet.(char(leads(jj).Name)).Tprima(kk);
                        detectedBeats(kk).TOff = delineationStruct.wavedet.(char(leads(jj).Name)).Toff(kk);
                        detectedBeats(kk).TTipo = delineationStruct.wavedet.(char(leads(jj).Name)).Ttipo(kk);
                        detectedBeats(kk).normalizeNaN();
                        leads(jj).addMarker(detectedBeats(kk));
                    end
                    recording.addLead(leads(jj));
                end
                
                % multilead delineation
                if isfield(delineationStruct.wavedet, 'multilead')
                    numberOfDetectedBeats = length(delineationStruct.wavedet.multilead.Pon);
                    detectedBeats = IspEcgFramework.data.BeatMarker.empty(numberOfDetectedBeats, 0);
                    for jj = 1:numberOfDetectedBeats
                        detectedBeats(jj) = IspEcgFramework.data.BeatMarker();
                        detectedBeats(jj).POn = delineationStruct.wavedet.multilead.Pon(jj);
                        detectedBeats(jj).PPeak = delineationStruct.wavedet.multilead.P(jj);
                        detectedBeats(jj).POff = delineationStruct.wavedet.multilead.Poff(jj);
                        detectedBeats(jj).QrsFiducial = delineationStruct.wavedet.multilead.qrs(jj);
                        detectedBeats(jj).QrsOn = delineationStruct.wavedet.multilead.QRSon(jj);
                        detectedBeats(jj).QPeak = delineationStruct.wavedet.multilead.Q(jj);
                        detectedBeats(jj).RPeak = delineationStruct.wavedet.multilead.R(jj);
                        detectedBeats(jj).SPeak = delineationStruct.wavedet.multilead.S(jj);
                        detectedBeats(jj).QrsOff = delineationStruct.wavedet.multilead.QRSoff(jj);
                        detectedBeats(jj).TOn = delineationStruct.wavedet.multilead.Ton(jj);
                        detectedBeats(jj).TPeak = delineationStruct.wavedet.multilead.T(jj);
                        detectedBeats(jj).TPrima = delineationStruct.wavedet.multilead.Tprima(jj);
                        detectedBeats(jj).TOff = delineationStruct.wavedet.multilead.Toff(jj);
                        detectedBeats(jj).TTipo = delineationStruct.wavedet.multilead.Ttipo(jj);
                        detectedBeats(jj).normalizeNaN();
                        recording.addMultileadMarker(detectedBeats(jj));
                    end
                end
                
                % physionet annotations
                if isfield(ecgWrapper, 'ECG_annotations')
                    if any(strcmp(properties(ecgWrapper), 'ECG_annotations'))
                        numberOfAnnotations = length(ecgWrapper.ECG_annotations.time);
                        for jj = 1:length(recording.Leads)
                            disp(['doing annotations ' char(recording.Name) ' Lead ' num2str(jj) ' in Recording ' char(recording.Name)]);
                            for kk = 1:int32(length(recording.Leads(jj).Markers))
                                %disp(['doing annotation ' num2str(kk) ' in ' char(recording.Name) ' Lead ' num2str(jj) ' in Recording ' char(recording.Name)]);
                                if isa(recording.Leads(jj).Markers(kk), 'IspEcgFramework.data.BeatMarker')
                                    for ll = 1:numberOfAnnotations
                                        if IspEcgFramework.data.BeatType.isBeatAnnotation(ecgWrapper.ECG_annotations.anntyp(ll)) && recording.Leads(jj).Markers(kk).containsIndex(ecgWrapper.ECG_annotations.time(ll))
                                            recording.Leads(jj).Markers(kk).AnnotatedType = IspEcgFramework.data.BeatType.getByAnnotationCharacterToNumber(ecgWrapper.ECG_annotations.anntyp(ll));
                                            break;
                                        end
                                    end
                                end
                            end
                        end
                        if isfield(delineationStruct.wavedet, 'multilead')
                            disp(['doing multilead annotations in ' char(recording.Name)]);
                            numberOfAnnotations = length(ecgWrapper.ECG_annotations.time);
                            for kk = 1:int32(length(recording.MultileadMarkers))
                                %disp(['doing multilead annotation ' num2str(kk) ' in ' char(recording.Name)]);
                                if isa(recording.Leads(jj).Markers(kk), 'IspEcgFramework.data.BeatMarker')
                                    for ll = 1:numberOfAnnotations
                                        if recording.MultileadMarkers(kk).containsIndex(ecgWrapper.ECG_annotations.time(ll))
                                            recording.MultileadMarkers(kk).AnnotatedType = IspEcgFramework.data.BeatType.getByAnnotationCharacterToNumber(ecgWrapper.ECG_annotations.anntyp(ll));
                                            break;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                workerResults(ii) = recording;
            end
            for indexVar = 1:length(workerResults)
                data.addRecording(workerResults(indexVar));
            end
        end
    end
end