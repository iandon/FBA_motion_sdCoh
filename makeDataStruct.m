function [dataStruct] = makeDataStruct(dataStruct,procedure,params)


numBlocks = params.block.numBlocks;
numTrials = params.trial.numTrialsPerBlock;

sdCohVect = stim.sdVals(length(stim.sdVals):-1:1);

numLevels = length(sdCogVect);

dataStruct.sdCohVect = sdCohVect;
dataStruct.ses.propCorr.allTrials = nan(numTrials*numBlocks,numLevels);
dataStruct.ses.numCorr = nan(1,numLevels);
dataStruct.ses.numTrialsLevel = zeros(1,numLevels);

dataStruct.block = cell(numBlocks,1);


for b = 1:numBlocks
    dataStruct.block{b}.propCorr.allTrials = nan(numTrials,numLevels);
    dataStruct.block{b}.numCorr = nan(1,numLevels);
    dataStruct.block{b}.numTrialsLevel = zeros(1,numLevels);
    for t = 1:numTrials
        currColumn = find(sdCohVect == procedure{b}{t}.sdCoh);
        
        %count number of trials per level
        dataStruct.ses.numTrialsLevel(currColumn) = dataStruct.ses.numTrialsLevel(currVectColumn)+1;
        dataStruct.block{b}.numTrialsLevel(currColumn) = dataStruct.ses.numTrialsLevel(currVectColumn)+1;
        
        %row determined by number of trial per level SO FAR
        currRowSes = dataStruct.ses.numTrialsLevel(currColumn);
        currRowBlock = dataStruct.block{b}.numTrialsLevel(currColumn);
        
        %record correctness (correct, incorrect, or no response)
        dataStruct.ses.propCorr.allTrials(currRowSes,currColumn) = procedure{b}{t}.correct;
        dataStruct.block{b}.propCorr.allTrials(currRowBlock,currColumn) = procedure{b}{t}.correct;
        
        dataStruct.ses.numCorr(currColumn) = dataStruct.ses.numCorr(currColumn) + (1==procedure{b}{t}.correct);
        dataStruct.block{b}.numCorr(currColumn)  = dataStruct.block{b}.numCorr(currColumn)  + (1==procedure{b}{t}.correct);
        
    end
end