function [response, timing, quitProg] = showScanStimulus(params,...
    stimulus, t0, timeFromT0)
% [response, timing, quitProg] = showStimulus(display,stimulus, ...
%           [time0 = GetSecs], [timeFromT0 = true])
%
% Inputs
%   params:    vistadisp display structure
%   stimulus:   vistadisp stimulus structure (e.g., see doRetinotopyScan.m)
%   t0:         time the scan started in seconds acc to PsychtoolBox
%               GetSecs function. By default stimulus timing is relative to
%               t0. If t0 does not exist it is created at the start of this
%               program.
%   timeFromT0: boolean. If true (default), then time each screen flip from
%               t0. If false, then time each screen flip from last screen
%               flip. The former is typically used for fMRI, where we want
%               to avoid accumulation of timing errors. The latter may be
%               more useful for ECoG/EEG where we care about the precise
%               temporal frequency of the stimulus.
% Outputs:
%   response:   struct containing fields
%                   keyCode: keyboard response at each frame, if any; if
%                           no response record a 0);
%                   secs: time of each response in seconds ?? verify
%                   flip:   time of each screen flip measured by PTB
%   timing:     float indicating total time of experiment
%   quitProg:   Boolean to indicate if experiment ended by hitting quit key
%
%
% HISTORY:
% 2005.02.23 RFD: ported from showStimulus.
% 2005.06.15 SOD: modified for OSX. Use internal clock for timing rather
%                 than framesyncing because getting framerate does not
%                 always work. Using the internal clock will also allow
%                 some "catching up" if stimulus is delayed for whatever
%                 reason. Loading mex functions is slow, so this should be
%                 done before callling this program.
% 2011.09.15  JW: added optional input flag, timeFromT0 (default = true).
%                 true, we time each screen flip from initial time (t0). If
%                 false, we time each screen flip from the last screen
%                 flip. Ideally the results are the same.

% input checks
if nargin < 2
    help(mfilename);
    return;
end
if nargin < 3 || isempty(t0)
    t0 = GetSecs; % "time 0" to keep timing going
end

if notDefined('timeFromT0'), timeFromT0 = true; end

% Get the display parameters
display = params.display;

% quit key
quitProgKey = params.quitProgKey;

% some variables
nFrames = length(stimulus.seq);
nImages = length(stimulus.textures);
response.keyCode = zeros(length(stimulus.seq),1); % get 1 buttons max
response.secs = zeros(size(stimulus.seq));        % timing
quitProg = 0;
response.flip = [];
response.glove = zeros(length(stimulus.seq), 5);

% go
HideCursor();
fprintf('[%s]:Running. Hit %s to quit.\n',mfilename, quitProgKey);

% for screenshots
tic;

if contains(params.sensoryDomain,'tactile','IgnoreCase',true)
    % present the tactile stimulus
    presentVibrotactileStimulus(params.VTSDevice);
end

%initialize counter
frame = 1;

for frame = 1:nFrames
    
    %--- update display
    % If the sequence number is positive, draw the stimulus and the
    % fixation.  If the sequence number is negative, draw only the
    % fixation.
    % put in an image
    imgNum = mod(stimulus.seq(frame)-1,nImages)+1;
    % draw fixation if stimulus.fixseq is not 0
    if stimulus.fixSeq(frame) == 0
        Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.dstRect);
    elseif stimulus.fixSeq(frame) == 55
        drawFixation(params); %draws hand stimulus
        Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), [], stimulus.dstRect2(frame,:));
    else
        Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.dstRect);
        drawFixation(params,stimulus.fixSeq(frame));
    end
    
    
    %--- timing
    waitTime = getWaitTime(stimulus, response, frame,  t0, timeFromT0);
    
    %--- get inputs (subject or experimentor)
    %--- with 10 ms sloptime the loop is not entered at 60 Hz,
    %    frame-by-frame texture drawing
    while(waitTime<0)
        
        % Check for serial port if we are at UMC-3T or UMC-7T or UMC-ECOG
        switch params.site
            case {'umc3t' 'umc7t' 'umcecog'}
                
                % At these sites, the subject response is sent through a
                % serial port which KbCheck cannot read, so we use
                % PsychToolbox' IOPort
                [output, ssSecs] = deviceUMC('button', params.siteSpecific.port);
                if output > 49 % 49 is the UMC trigger code; button responses are 65-68.
                    response.keyCode(frame) = output;
                    response.secs(frame)    = ssSecs - t0;
                end
        end
        
        % Scan the keyboard for subject response
        [ssKeyIsDown,ssSecs,ssKeyCode] = KbCheck(-1);
        
        if ssKeyIsDown
            str = KbName(find(ssKeyCode));
            if iscell(str)
                str = str{1};
            end
            str = str(1);
            
            switch str
                case quitProgKey
                    % Quit the experiment gracefully
                    quitProg = 1;
                    break; % out of while loop
                    
                case params.triggerKey
                    switch params.site
                        case {'nyu3t'}
                            % do nothing as this is the trigger key from the scanner
                        otherwise
                            % record the subject response
                            response.keyCode(frame) = str;
                            response.secs(frame)    = ssSecs - t0;
                    end
                    
                otherwise
                    % record the subject response
                    response.keyCode(frame) = str;
                    response.secs(frame)    = ssSecs - t0;
            end
        end
        
        % if there is time release cpu
        if(waitTime<-0.02)
            WaitSecs(0.01);
        end
        
        % timing
        waitTime = getWaitTime(stimulus, response, frame, t0, timeFromT0);
    end
    
    if quitProg
        fprintf('[%s]:Quit signal received.\n',mfilename);
        break;
    end
        
    %--- update screen
    VBLTimestamp = Screen('Flip',display.windowPtr);
    imageArray = Screen('GetImage', display.windowPtr);

    % take screenshot
    if isfield(params, 'path_for_screenshots') && ~isempty(params.path_for_screenshots)
        image_onset = toc;
        screenshot_file = sprintf('img%012.f.jpg', image_onset * 10e6);
        imwrite(imageArray, fullfile(params.path_for_screenshots,  screenshot_file), 'jpg');
    end
    
    % Send trigger, if requested (if stimulus.trigSeq > 0)
    if isfield(stimulus, 'trigSeq') && ~isempty(stimulus.trigSeq) && ...
            stimulus.trigSeq(frame) > 0
        switch lower(params.site)
            case 'nyuecog'
                PsychPortAudio('Start', params.siteSpecific.AudPnt, 1, 0);
            case 'nyumeg'
                PTBSendTrigger(stimulus.trigSeq(frame), 0);
            case 'nyueeg' % in case we ever decide to do EEG....
                % NetStation('Event','flip',VBLTimestamp);
                thisCode = sprintf('%4.0d', stimulus.trigSeq(frame));
                NetStation('Event', thisCode,VBLTimestamp);
            case 'umcecog'
                if params.siteSpecific.port_triggers ~= -1
                    fprintf(params.siteSpecific.port_triggers, '%c', stimulus.trigSeq(frame));
                end
            case 'umcor'
                if params.siteSpecific.port_triggers ~= -1
                    fprintf(params.siteSpecific.port_triggers, '%c', 1);
                end
        end
    end
    
    if params.useDataGlove
        response.glove(frame,:) = sampleDataglove (params.glovePointer);
    end
    
    % Record the flip time
    response.flip(frame) = VBLTimestamp;
    
end

% that's it
ShowCursor;
timing = GetSecs-t0;
fprintf('[%s]:Stimulus run time: %f seconds [should be: %f].\n',mfilename,timing,max(stimulus.seqtiming));

return;


function waitTime = getWaitTime(stimulus, response, frame, t0, timeFromT0)
% waitTime = getWaitTime(stimulus, response, frame, t0, timeFromT0)
%
% If timeFromT0 we wait until the current time minus the initial time is
% equal to the desired presentation time, and then flip the screen.
% If timeFromT0 is false, then we wait until the current time minus the
% last screen flip time is equal to the desired difference in the
% presentation time of the current flip and the prior flip.

if timeFromT0
    waitTime = (GetSecs-t0)-stimulus.seqtiming(frame);
else
    if frame > 1
        lastFlip = response.flip(frame-1);
        desiredWaitTime = stimulus.seqtiming(frame) - stimulus.seqtiming(frame-1);
    else
        lastFlip = t0;
        desiredWaitTime = stimulus.seqtiming(frame);
    end
    % we add 10 ms of slop time, otherwise we might be a frame late.
    % This should NOT cause us to be 10 ms early, because PTB waits
    % until the next screen flip. However, if the refresh rate of the
    % monitor is greater than 100 Hz, this might make you a frame
    % early. [So consider going to down to 5 ms? What is the minimum we
    % need to ensure that we are not a frame late?]
    waitTime = (GetSecs-lastFlip)-desiredWaitTime + .010;
end
