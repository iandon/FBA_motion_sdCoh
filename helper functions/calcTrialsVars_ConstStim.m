function procedure = calcTrialsVars_ConstStim
global params;  
numTrials = params.trial.numTrialsPerBlock; % should be 180




numRepeats = 6; %how many times does each trial type repeat?
                   % 8 SDs, 2 baseAngles, 2 angleDirs, 1 cueType = 32
                   %6 repeats = 192 trials per block


baseAnglePossible = params.stim.baseAngles;
angleDirPossible  = [1, -1]; % ccw vs cw
cueTypePossible  = 0; %just Neutral
sdPossible = params.stim.sdVals;



[baseAngle,angleDir,cueType,sdCoh,repeat] = ndgrid(baseAnglePossible,angleDirPossible,cueTypePossible,sdPossible,1:numRepeats);

ord = randperm(numTrials);

baseAngle = baseAngle(ord);
angleDir  = angleDir(ord);
cueType  = cueType(ord);
sdCoh = sdCoh(ord);

targetAngle = baseAngle+(angleDir*params.stim.angleDiff);

ansResp = (angleDir == 1)+1;
% SOA = repmat(params.ISI.preDurVect(blockNum),[numTrials,1]);


        
procedure = cell(numTrials,1);
for i = 1:numTrials
    procedure{i}.baseAngle = baseAngle(i);
    procedure{i}.angleDir  = angleDir(i);
    procedure{i}.targetAngle = targetAngle(i);
    procedure{i}.cueType  = cueType(i);
    procedure{i}.sdCoh  = sdCoh(i);
    procedure{i}.ansResp  = ansResp(i);
    procedure{i}.trialIndex = i;
    procedure{i}.SOA = params.ISI.preDur;
end