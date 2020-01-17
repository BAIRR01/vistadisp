function [startTime,endTime] = presentVibrotactileStimulus(params)
% Runs a simple tactile experiment, the signal coded in VibrotactileStimulus is presented through the device connected
% to VTSDeviceSess
%

fprintf('\nStarting the vibrotactile stimulation\n');
startTime = GetSecs();

% VTSDevice.startBackground; % high latency

% start presentation
NI_DAQmxStartTask(params.analogOutputTaskHandle(1));

endTime = GetSecs();




