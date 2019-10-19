function params = setFixationParams(params, stimulus)
% setParams - set parameters for different retinotopy scans 
%
% params = setFixationParams(params, stimulus)

% X,Y center location for fixation
params.display.fixX = (stimulus.dstRect(1)+stimulus.dstRect(3))/2;
params.display.fixY = (stimulus.dstRect(2)+stimulus.dstRect(4))/2;

% Fixation size in visual angle and in pixels
params.display.fixSizeAngle  = 0.30;
params.display.fixSizePixels = round(angle2pix(params.display,params.display.fixSizeAngle));

% Default colors are red and green ([R G B Alpha]); 3 is black
params.display.fixColorRgb   = [255 0 0 255; 0 255 0 255; 0 0 0 255]; 

% Time within which a response is required for a detection to count as
%   correct
params.fix.responseTime       = [.01 3]; % seconds


switch lower(params.fixation)
    case 'disk'
        % all parameters are set in the defaults above
        
    case '4 color dot'
        % all parameters are set in the defaults above except for colors
        params.display.fixColorRgb  = ...
            [200 0 0 192;
            200 0 0 128;
            0 145 0 192;
            0 145 0 128;
            ];                       

        params.display.fixColorRgb  = ...
            [255 0 0 255;
            0 0 0 255;
            0 255 0 255;
            0 0 0 255;
            ];          
        
        
    case {'cross' 'crossdisk'}
        
        % First, find the points on a cross whose center is defined by
        %  (params.display.fixX, params.display.fixY) and whose length is
        %  +/- params.display.fixSizePixels
        pointsInLineParallel = -params.display.fixSizePixels:params.display.fixSizePixels;
        pointsInLinePerpendicular = zeros(size(pointsInLineParallel));
        dim.ycoord = params.display.fixY + [pointsInLineParallel pointsInLinePerpendicular] ;
        dim.xcoord = params.display.fixX + [pointsInLinePerpendicular pointsInLineParallel];
        params.display.fixCoords = [dim.xcoord;dim.ycoord];
        
        % Then specify the size of the dots making up the lines (ie the
        % thickness of the lines in pixels)
        params.display.fixSizeAngle  = 0.03;
        
        if strcmp(params.fixation, 'cross')
            params.display.fixSizePixels = ceil(angle2pix(params.display,params.display.fixSizeAngle));
        else
            params.display.fixSizePixels(2) = ceil(angle2pix(params.display,params.display.fixSizeAngle));
        end
    
    case 'hand'
        % image presentation rectangles
        params.display.handImageDims = stimulus.handImageDims;
        params.display.handImageCoords = CenterRectOnPointd(params.display.handImageDims, params.display.fixX, params.display.fixY);
        
        % load the hand image
        [params.display.handImage,~,alpha] = imread(stimulus.handImagePath);
        % add alpha values to the image
        params.display.handImage(:, :, 4) = alpha;

   
    otherwise
        error('Unknown fixationType!');
end

