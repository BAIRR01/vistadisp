function [startTime,endTime] = presentVibrotactileStimulus(VTSDeviceSess)
% Runs a simple tactile experiment, the signal coded in VibrotactileStimulus is presented through the device connected
% to VTSDeviceSess
%

fprintf('\nStarting the vibrotactile stimulation\n');
startTime = GetSecs();

[data,timeStamps,triggerTime] = VTSDeviceSess.startForeground;

endTime = GetSecs();

fprintf('\nEnded the vibrotactile stimulation\n');




