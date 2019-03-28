function params = initializeSiteSpecificEnvironment(params)

switch lower(params.site)    
    case 'nyu3t'
        % Do nothing
    case 'nyumeg'
        
        % Initialize eye tracker
        
        PTBInitStimTracker;
        global PTBTriggerLength 
        PTBTriggerLength = 0.005;

        % Q do we need to initialize a trigger channel?
        
    case 'nyuecog'
        % Set up triggers via audio cable
        fs = 16000;
        InitializePsychSound;
        
        AudPnt = PsychPortAudio('Open', [], [], 0, fs, 1);
        
        % creating the square wave (or appending it to an audio stimulus as the first channel in the stereo file)
        % To make trigger.wav:
        %       square = [ones(1,fs/1000*50) -1*ones(1,fs/1000*50)];
        %       audiowrite('trigger.wav',square,fs);        
        wavdata = audioread('trigger.wav');
        
        % play stimuli (one channel is a square wave)
        PsychPortAudio('FillBuffer', AudPnt,wavdata');
        params.siteSpecific.AudPnt = AudPnt;
        
    case {'umc7t' 'umc3t'}
        % Initialize the serial port for UMC
        
        % First, find the serial port
        portName = FindSerialPort([],1,1);
        
        % Open serial port 
        if ~isempty(portName)

            params.siteSpecific.port = deviceUMC('open',portName);
        
        else
            
            % For testing on a computer without a serial port, deviceUMC.m
            % can take a negative number as portname input and still run
            params.siteSpecific.port = -1; % deviceUMC('open',portName);
        
        end
        
        if strcmp(params.site, 'umc7t')
            params.display.verticalOffset = 0; % pixels (positive means move the box higher)
        end 
     
    case {'umcecog' 'umcor'}
        
        % necessary to run the correct mex files on windows for
        % psychtoolbox
        fix_psychtoolbox_path();
        
        % Button Box Serial Port (the same as fMRI)
        COM_PORT_BTNBOX = 'COM5';
        
        if ~isempty(COM_PORT_BTNBOX)
            try
                params.siteSpecific.port = deviceUMC('open', COM_PORT_BTNBOX);
            catch
                params.siteSpecific.port = -1; % deviceUMC('open',portName);
            end
        else
            params.siteSpecific.port = -1; % deviceUMC('open',portName);
        end

        % Triggers Serial Port
        COM_PORT_TRIGGERS = 'COM6';
        if ~isempty(COM_PORT_TRIGGERS)
            try
                portName = serial(COM_PORT_TRIGGERS);
                fopen(portName);
                params.siteSpecific.port_triggers = portName;
            catch
                params.siteSpecific.port_triggers = -1; % deviceUMC('open',portName);
            end
        else
            params.siteSpecific.port_triggers = -1;
        end
        
        if strcmpi(params.site, 'umcor')
            params.quitProgKey = '1';
        end
        
    otherwise
        % do nothing
end