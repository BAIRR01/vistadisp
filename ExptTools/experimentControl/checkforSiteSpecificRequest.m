function checkforSiteSpecificRequest(experimentSpecs,whichSite, sensoryDomain)

switch lower(experimentSpecs.sites{whichSite})
    case 'nyuecog'
        % calibrate display
        NYU_ECOG_Cal(sensoryDomain);        
        % Check paths
        if isempty(which('PsychtoolboxVersion'))
            error('Please add Psychtoolbox to path before running')
        end
    otherwise
        % for now, do nothing
end

end
