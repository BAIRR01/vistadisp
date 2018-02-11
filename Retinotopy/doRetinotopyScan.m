function doRetinotopyScan(params)
% doRetinotopyScan - runs retinotopy scans
%
% doRetinotopyScan(params)
%
% Runs any of several retinotopy scans
%
% 99.08.12 RFD wrote it, consolidating several variants of retinotopy scan code.
% 05.06.09 SOD modified for OSX, lots of changes.
% 11.09.15 JW added a check for modality. If modality is ECoG, then call
%           ShowScanStimulus with the argument timeFromT0 == false. See
%           ShowScanStimulus for details. 

% defaults
if ~exist('params', 'var'), error('No parameters specified!'); end
if ~isfield(params, 'skipSyncTests'), skipSyncTests = true;
else,                                 skipSyncTests = params.skipSyncTests; end

% make/load stimulus
stimulus = makeRetinotopyStimulusFromFile(params);

fprintf('[%s]: Experiment duration (seconds): %6.3f\n', mfilename, stimulus.seqtiming(end))
% WARNING! ListChar(2) enables Matlab to record keypresses while disabling
% output to the command window or editor window. This is good for running
% experiments because it prevents buttonpresses from accidentally
% overwriting text in scripts. But it is dangerous because if the code
% quits prematurely, the user may be left unable to type in the command
% window. Command window access can be restored by control-C.
ListenChar(2);

% loading mex functions for the first time can be
% extremely slow (seconds!), so we want to make sure that
% the ones we are using are loaded.
KbCheck;GetSecs;WaitSecs(0.001);

try
    % check for OpenGL
    AssertOpenGL;
    
    % added a checkbox to ret gui allowing user to specify whether PTB
    % should skip sync tests or not:
    % Applications2/Retinotopy/standard/doRetinotopyScan.m
    Screen('Preference','SkipSyncTests', skipSyncTests);
    
    % Open the screen
    xy = params.display.numPixels; % store screen dimensions in case they change
    params.display                = openScreen(params.display);
    params.display.triggerKey     = params.triggerKey;
    
    % Reset Fixation parameters if needed (ie if the dimensions of the
    % screen after opening do not match the dimensions specified in the
    % calibration file) 
    if isequal(xy, params.display.numPixels)
        % OK, nothing changed
    else
        params = retSetFixationParams(params, params.experiment);
    end
    
    % to allow blending
    Screen('BlendFunction', params.display.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Store the images in textures
    stimulus = createTextures(params.display,stimulus);
    
    % If necessary, flip the screen LR or UD  to account for mirrors
    % We now do a single screen flip before the experiment starts (instead
    % of flipping each image). This ensures that everything, including
    % fixation, stimulus, countdown text, etc, all get flipped.
    retScreenReverse(params, stimulus);
 
    
    for n = 1:params.repetitions
        % set priority
        Priority(params.runPriority);
        
        % reset colormap?
        retResetColorMap(params);
        
        % wait for go signal
        onlyWaitKb = false;
        pressKey2Begin(params.display, onlyWaitKb, [], [], params.triggerKey);

        
        % countdown + get start time (time0)
        [time0] = countDown(params.display,params.countdown,params.startScan, params.trigger);
        time0   = time0 + params.startScan; % we know we should be behind by that amount
        
        
        % go
        if isfield(params, 'modality') && strcmpi(params.modality, 'ecog')
            timeFromT0 = false;
        else, timeFromT0 = true;
        end        
        [response, timing, quitProg] = showScanStimulus(params,stimulus,time0, timeFromT0); %#ok<ASGLU>
        
        % reset priority
        Priority(0);
        
        % get performance
        [pc,rc] = getFixationPerformance(params.fix,stimulus,response);
        fprintf('[%s]: percent correct: %.1f\nreaction time: %.1f secs\n',mfilename,pc,rc);
        
        % save
        if params.savestimparams
            pth = fullfile(vistadispRootPath, 'Data');
            
            fname = sprintf('%s_%s', params.subjID, datestr(now,30));
            
            save(fullfile(pth, sprintf('%s.mat', fname)));
            
            fprintf('[%s]:Saving in %s.\n', mfilename, fullfile(pth, fname));
            
            writetable(stimulus.tsv, fullfile(pth, sprintf('%s.tsv', fname)), ...
                'FileType','text', 'Delimiter', '\t')
            
        end
        
        % don't keep going if quit signal is given
        if quitProg, break; end
        
    end
    
    % Close the one on-screen and many off-screen windows
    closeScreen(params.display);
    ListenChar(1)
    
catch ME
    % clean up if error occurred
    Screen('CloseAll'); 
    ListenChar(1)
    setGamma(0); Priority(0); ShowCursor;
    warning(ME.identifier, '%s', ME.message);
end


return;







