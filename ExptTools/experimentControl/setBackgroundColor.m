function params = setBackgroundColor(params)
% params = setBackgroundColor(params)
%
% Overwrite background grayscale value for color experiments for which the
% image pixel values have been squared so they are presented correctly
% combined with work with a linearized gamma table. 
%
% Also see s_MakeLocalizerExperiment and other scene experiments
%
% IG 2020


if contains(params.experiment, {'sixcatloc', 'objectdetection', 'scenefacelateral'})   
    params.display.backColorRgb = [repmat(round(params.display.maxRgbValue/4),1,3) params.display.maxRgbValue];
end