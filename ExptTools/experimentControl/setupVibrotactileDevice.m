function params = setupVibrotactileDevice(NIdaqRate, NIdaqNames, numOfStimulators, params)
% sets up the NIdaq device with number of channels equal to nrStimulators
% setupVibrotactileDevice (VTSOptions)
%
% Required Input:
%
% VTSOptions    : Struct containing inputs for vibrotactile experiment
%
%% Check for Options and inputs

if ~exist('numOfStimulators', 'var')
    error ('\n\n numOfStimulators is a required input\n\n')
end
if ~exist('NIdaqRate', 'var')
    error ('\n\nNIdaqRate is a required input\n\n')
end

%% Set up the session

% Initialize the session and parameters
VTSDevice       = daq.createSession('ni');
VTSDevice.Rate  = NIdaqRate; % Rate of operation (scans/s)


% DAQ names (each can run up to 10 stimulators)
NIdaqName = NIdaqNames;

% Add all the output channels to the session
for ii = 0:(numOfStimulators-1)
    stimName = sprintf('ao%d', ii);
    addAnalogOutputChannel(VTSDevice, NIdaqName, stimName, 'Voltage');
end


switch lower(params.site)
    case 'nyuecog' % add additional channel for trigger
        stimName = sprintf('ao%d', ii + 1);
        addAnalogOutputChannel(VTSDevice, NIdaqName, stimName, 'Voltage');
end
params.VTSDevice = VTSDevice;
fprintf('\nNIdaq box successfully initialized\n\n')
end
