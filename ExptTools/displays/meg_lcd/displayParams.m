function params = displayParams
% For MEG LCD projector, Sep 20, 2019
% Last calibrated: Using a ColorCAL MKII Colorimeter, on a tripod pressed
% against the MEG screen, while executing nyuCalibrateMonitorColorCal2.
% This function is an adapted version of PTB's CalibrateMonitorPhotometer.m
% (17 measurements, twice executed for each point)
%
%
% % CODE TO SAVE GAMMA TABLE
% % load in a measurement made from PTB's CalibrateMonitorPhotometer
% load('/Volumes/server/Projects/MEG/Calibration/MEG_Cal1_33points_v1.mat')
% 
% % use gammaTable 1, which is the powerlaw fit to the measurements
% g = gammaTable1;
% 
% % replicate to 256 x 3 for RGB (assuming 8 bits)
% gamma = [g g g];
% 
% % integers for lookup table
% gammaTable = round(gamma * 255);
% 
% % where to save?
% pth = '~/matlab/git/vistadisp/exptTools2/displays/meg_lcddisplayParams';
% 
% save(fullfile(pth, 'gamma'), 'gamma', 'gammaTable');


% Critical parameters
params.numPixels    = [1024 768];   % this is the correct native resolution
params.dimensions   = [26.5 19.6];  % cm, BUT CHECK THIS! measured on 09/30/19
%params.dimensions   = [30.6 19.6];  % cm, BUT CHECK THIS! measured on 09/30/19
%params.dimensions   = [29.8 18.7];  % cm, BUT CHECK THIS! Eline settings
params.distance     = 32.5;         % cm, CHECK THIS! Eline settings
params.frameRate    = 60;           % this is the correct native frame rate
params.cmapDepth    = 8;            % this is the correct bit depth for our experiment
params.screenNumber = 0;            % we usually mirror MEG, so 0 is correct

% Descriptive parameters
params.position = 'lying in MEG';
params.stereoFlag = 0;

