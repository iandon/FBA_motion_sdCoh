


initialsCell = {'LD','ID'}; %
numSesVect = [1,2]; %how many sessions for each observer?

runAll = 0; 
continueQ = 1;

for subj = 1:length(initialsCell)
    subjInitials = initialsCell{subj};
    addpath(sprintf('results/%s',initialsCell{subj}));
    for ses = 1:numSesVect(subj)
        currExpFile = dir(sprintf('results/%s/motionExp_results_%s_ses%d_*.mat',initialsCell{subj},initialsCell{subj},ses));
        load(sprintf('%s',currExpFile.name));
        if ses == 1
            [dataStruct.(subjInitials)] = makeDataStruct_mix(procedure,params,sesNum);
        else
            [dataStruct.(subjInitials)] = makeDataStruct_mix(procedure,params,sesNum,'dataStruct',dataStruct.(subjInitials));
        end
    end
    
    sprintf('Plots show data from %s',subjInitials)
    if subj < length(initialsCell) && ~runAll
        
        continueQ = input('Next subject? Y (1) or N (0) \n', 's'); continueQ=str2num(continueQ);
        if ~continueQ, return, end
    end
end
