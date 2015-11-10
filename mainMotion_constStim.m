clear all;
addpath(genpath('/users/purplab/Documents/MATLAB/ID_motion_FBA/sd_coh/helper functions'))
addpath(genpath('/users/Shared/Psychtoolbox'))
% addpath(genpath('/users/purplab/Documents/MATLAB/ID_motion_FBA/sd_coh/palamedes1_6_0'))


motion_params_constStim; %SET for each participant
global params;

homedir = pwd;  
addpath(genpath(strcat(homedir,'/mgl')));


params.eye.run = 0;
params.stairVars.run = 0;
params.stim.colorTest = 0;

%initials = 'test'; sesNum = '0';    
initials = input('Please enter subject initials: \n', 's'); initials = upper(initials);
params.subj.gender = input('Please enter subject GENDER: M/F/O \n', 's');
params.subj.age = input('Please enter subject AGE: \n', 's');
sesNumquest = input('Please enter the session number:\n', 's'); sesNum = str2double(sesNumquest); params.saveVars.sesNum = sesNum; params.sesVar.sesNum = sesNum;
sesTypequest = input('Test(0) or Training(1)? \n', 's'); sesType = str2double(sesTypequest); params.saveVars.sesType = sesType;
% TRAIN LOCATION is in Plexp_defs file -> Make sure it is the right one!

if (sesNumquest > 1) && ~strcmp(initials,params.saveVars.SubjectInitials)
     error('Check if settings file used is correct for this participant'); 
end




%%%%%%%%% set some general screen params %%%%%%%%% 
Screen('CloseAll');   
Screen('Preference', 'VisualDebugLevel', 1);
wPtr = Screen('OpenWindow',  params.screen.num, params.screen.bkColor, params.screen.rectPix);

%%%%%%%%% Load  new gamma table to fit the current screen %%%%%%%%%
    
startclut = Screen('ReadNormalizedGammaTable', params.screen.num); 
load(params.screen.calib_filename); 
new_gamma_table = repmat(calib.table, 1, 3);
Screen('LoadNormalizedGammaTable',wPtr,new_gamma_table,[]); 

Priority(MaxPriority(wPtr)); 
recal=0;
instructions(wPtr,recal); % print instructions

%%%%%%%%% If need make main screen black here 

%%%%%%%%% Initialize response and experiment data variables %%%%%%%%%
% trialstype: variable that carries cue location 1: LVF, 2: RVF 3: neutra
% central cue. RespType: indicate the direction CW or CCW of the LVF or RVF stim 
% resp = struct('rt', {[]}, 'key', {[]}, 'correct', {[]},'block',{[]});
% expData  = struct('angles',{[]},'trialsType',{[]},'respType',{[]},
% 'stairOrder',{[]},'dotCoh',{[]},'block',{[]},'stairs',{[]});



%%%%%%%%% eye-tracker %%%%%%%%%
%%%%%%%%% To initialize and calibrate %%%%%%%%%
%%%%%%%%% Do this at the begining of each session %%%%%%%%%
if params.eye.run
    Eyelink('Initialize'); %this establishes the connection to the eyelink
    el = prepEyelink(wPtr);
    edfFile = sprintf('%s%s%s%s.edf', initials, sesNum,dateTime(5:6),dateTime(10:11)); edfFileStatus = Eyelink('OpenFile', edfFile); %this creates the .edf file (doesn't like many characters in name, i think 6 or 8 max)
    if edfFileStatus ~= 0, fprintf('Cannot open .edf file. Exiting ...'); return; end
    cal = DoTrackerSetup(el); %This calibrates the eyelink . 
end

%%%%%%%%% Initialize fixation break structure %%%%%%%%%
fixBreak=struct('fixBreak',{0},'recal',{0},'currRunNum',{0},'numFixBreaks',{0},'breakTrack',{0},'breakRecent',{0});


%%%%%% Initialize block and trial parameters %%%%%%%


%%%% --------------      Start experiment  --------------%%%%%
correctTrial=zeros(params.trial.numTrialsPerBlock,params.block.numBlocks);
trialNum = 0;
stair = cell(params.block.numBlocks,params.stair.numStairs);
procedure = cell(params.block.numBlocks,1);
for b = 1:params.block.numBlocks
%     for stairNum = 1:params.stair.numStairs
%         stair{b}{stairNum} = PAL_AMPM_setupPM('stimRange',params.stair.stimRange,...
%                                            'priorAlphaRange',params.stair.priorAlphaRange,...
%                                            'priorBetaRange',params.stair.priorBetaRange,...
%                                            'gamma',params.stair.gamma,'lambda',params.stair.lambda,...
%                                            'PF',@PAL_Weibull,'numTrials',params.stair.numTrials,'marginalize',params.stair.marginalize);
%     end 
    procedure{b} = calcTrialsVars_ConstStim(b);
    blockBreak(wPtr, b);
    if params.eye.run && (b > 1)
        EyelinkDoDriftCorrect(el, params.screen.centerPix(1),...
                              params.screen.centerPix(2), 1, 1);
    end
    t=0;
    while t < params.trial.numTrialsPerBlock
        t=t+1;
        recal = 0;
        
        [fixBreak.fixBreak, respTrial, timestamp] = trial(wPtr, procedure{b}{t}.targetAngle,procedure{b}{t}.baseAngle, b, sesNum, t,...
                                                          procedure{b}{t}.cueType,procedure{b}{t}.SOA,procedure{b}{t}.dotCoh);
                                                      %trial(wPtr,trialAngle,baseAngle,blockNum,sesNum, trialNum ,cueType,SOA,dotCoh)
        % update trial parameters after response
        procedure{b}{t}.timestamp=timestamp;
        if fixBreak.fixBreak
            disp((sprintf(' block %d, trial %d is a fixation break',b,t)));
            [procedure{b}, fixBreak, recal] = breakProc(procedure{b},t,wPtr,el,fixBreak);
            t=t-1;%%% reset trial counter by 1
        else
            correctTrial(b,t) = respTrial.correct;
            procedure{b}{t}.correct = respTrial.correct;
            procedure{b}{t}.rt = respTrial.rt;
            procedure{b}{t}.key = respTrial.key;
            disp(sprintf('Elapsed time for block %d, trial %d is %G',b,t,timestamp.ts));
%             
%             stair{b}{procedure{b}{t}.stairNum} = PAL_AMPM_updatePM(stair{b}{procedure{b}{t}.stairNum},procedure{b}{t}.correct);
           
        end
        if recal; breakFix.Block.recalCount = breakFix.Block.recalCount + 1; recalProc(el, wPtr); end

    end
    
    correctPercent = 100*(correctProp/nTrials);
    blockBreak(wPtr, b, correctPercent);

    save(blockFileName, 'expData', 'results','sesNum', 'params', 'breakFix', 'stair');
    if params.eye.run, Eyelink('StopRecording'); Eyelink('Message', sprintf('Block # %d Complete', b));end
    
    
    
    Screen('Close');
end

if params.eye.run; Eyelink('ReceiveFile', edfFile, direc,1); Eyelink('CloseFile'); Eyelink('Shutdown'); end

Screen('Close'); Priority(0);
Screen('CloseAll'); ShowCursor;
%%%%%-------------     End the experiment    ----------%%%%%

%%%%%------------- Save all experiment data ----------%%%%%
cd(direc);
date = sprintf('Date:%02d/%02d/%4d  Time:%02d:%02d:%02i ', c(2),c(3),c(1),c(4),c(5),ceil(c(6)));
save(saveExpFile);
cd(homedir);

% %%%%%%% run some analysis %%%%%%%
% totalTrials=(params.trial.numTrialsPerBlock*numBlocks);
c = clock;
homedir = pwd; 
dirc = sprintf('results/%s/%s', params.save.expTypeDirName,initials);
mkdir(dirc); cd(dirc)
if params.eye.run; Eyelink('ReceiveFile', ELfileName, dirc,1); Eyelink('CloseFile'); Eyelink('Shutdown'); end
Screen('Close');
date = sprintf('Date:%02d/%02d/%4d  Time:%02d:%02d:%02i ', c(2),c(3),c(1),c(4),c(5),ceil(c(6)));
saveExpFile = sprintf('%s_results_%s_ses%d_%02d_%02d_%4d_time_%02d_%02d_%02i.mat',...
                      params.save.fileName, initials, sesNum,...
                      c(2),c(3),c(1),c(4),c(5),ceil(c(6)));
          
save(saveExpFile ,'procedure', 'results','sesNum', 'params', 'date', 'stair', 'breakFix');

cd(homedir);
%%%%%--------------------------------------------------%%%%%

%delete('tmpData.mat');
Screen('LoadNormalizedGammaTable',params.screen.num,startclut,[]);
Screen('CloseAll');
disp('Done!');
%%