function [params, quitProg] = checkforSensoryDomainSpecificRequest(params)

% See if we need to initialize the data glove (NOTE Should this go in
% a site/domainspecific function?
quitProg = false;

switch lower(params.sensoryDomain)
    case 'motor'
        
        try params.glovePointer = initializeDataGlove;
        catch ME
           warning(ME.identifier, ME.message)
           %str = input('Failure to initialize data glove. Continue anyway? (y/n)', 's');
%            if strcmpi(str, 'y')
%                params.glovePointer = NaN; 
%            else
%                quitProg = true; return; 
%            end

            % Continue without dataglove?
            prompt = {'Continue anyway? (y/n)'};
            defaults = {'y'};
            answer = inputdlg(prompt, 'Failure to initialize data glove ', [1 50], defaults);
            if strcmpi(answer, 'y')
                params.glovePointer = NaN;
                disp('Continuing without data glove')
            else
                %quitProg = true; return; 
                return;
            end                
        end
        
    case 'tactile'
        % put any initialization of VTS here?
    otherwise
        % do nothing
end

end
