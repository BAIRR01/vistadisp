function [startTime,endTime] = presentVibrotactileStimulus(VTSDevice)
% Runs a simple tactile experiment, the signal coded in VibrotactileStimulus is presented through the device connected
% to VTSDeviceSess
%

fprintf('\nStarting the vibrotactile stimulation\n');
startTime = GetSecs();

VTSDevice.startBackground;

endTime = GetSecs();




