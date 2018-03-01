function params = setFixationParams(params)
% setParams - set parameters for different retinotopy scans 
%
% params = setFixationParams(params)

dim.x = params.display.numPixels(1);
dim.y = params.display.numPixels(2);

params.display.fixSizeAngle  = 0.15;
params.display.fixSizePixels = round(angle2pix(params.display,params.display.fixSizeAngle));

params.fix.responseTime       = [.01 3]; % seconds

switch(lower(params.display.fixType))
        
     case {'4 color dot'}
        params.display.fixX = round(dim.x./2);
        params.display.fixY = round(dim.y./2);
        params.display.fixColorRgb  = ...
            [200 0 0 192;
            200 0 0 128;
            0 145 0 192;
            0 145 0 128;
            ];        
        
    case {'disk','double disk'}
        params.display.fixX          = round(dim.x./2);
        params.display.fixY          = round(dim.y./2);        
        params.display.fixColorRgb   = [255 0 0 255; 0 255 0 255]; 
   
    otherwise
        error('Unknown fixationType!');
end
