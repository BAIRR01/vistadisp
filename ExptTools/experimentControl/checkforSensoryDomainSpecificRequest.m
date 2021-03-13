function [params] = checkforSensoryDomainSpecificRequest(params)

% See if we need to initialize the data glove (NOTE Should this go in
% a site/domainspecific function?
quitProg = false;

switch lower(params.sensoryDomain)
    case 'motor'
        
        try
            params.glovePointer = initializeDataGlove;
            params.useDataGlove = true;
        catch ME
            %warning(ME.identifier, ME.message)
            %str = input('Failure to initialize data glove. Continue anyway? (y/n)', 's');
            %            if strcmpi(str, 'y')
            %                params.glovePointer = NaN;
            %            else
            %                quitProg = true; return;
            %            end
            
            % Continue without dataglove?
            prompt = {'Continue anyway? (y/n)'};
            defaults = {'y'};
            answer = inputdlg(prompt, 'Failure to initialize data glove ', [1 50], defaults);
            if strcmpi(answer, 'y')
                params.useDataGlove = false;
                disp('Continuing without data glove...')
            else
                %quitProg = true; return;
                return;
            end
        end
        if  contains (params.modality, 'ecog','IgnoreCase',true)
            params.calibration      = 'BAIR_ACER';
            
        end
        
    case {'tactile' 'tactile-visual'}
        stimPath = fullfile(vistadispRootPath, 'StimFiles', params.loadMatrix);
        load(stimPath, 'stimulus');
  
        % Initialize the vibrotactile device
        params = setupVibrotactileDevice(stimulus.NIdaqRate, stimulus.NIdaqNames, stimulus.numOfStimulators,params);
        % create analog output channel
        params.analogOutputChannel(1) = params.VTSDevice.Channels(1);
        % create task handle for this channel
        params.analogOutputTaskHandle(1) = params.analogOutputChannel(1).TaskHandle;
        % configure handle
        NI_DAQmxCfgSampClkTiming(params.analogOutputTaskHandle(1), stimulus.NIdaqRate, size(stimulus.vibrotactileStimulus, 1));
        % queue stimulus
        NI_DAQmxWriteAnalogF64(params.analogOutputTaskHandle(1), stimulus.vibrotactileStimulus);
%  % start presentation
% NI_DAQmxStartTask(params.analogOutputTaskHandle(1));
       
%         queueOutputData(params.VTSDevice, stimulus.vibrotactileStimulus);
%         prepare(params.VTSDevice);%slightly improve timing
        
        clear stimulus
    otherwise
        % do nothing
end

end
