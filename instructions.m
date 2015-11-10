function instructions(wPtr,recal)
global params;

instruct = 'Indicate whether the motion direction was more UPWARD (1) or DOWNWARD (2)';

% keys = 'Track the overall direction of the stimulus with your eyes as best as possible.';
% start ='Do not track one individual dot - rather try to track the global motion';
start ='Press SPACEBAR to start the experiment';

recalibrate='Oops too many fixation breaks. Please call the experimenter to recalibrate';

Screen('TextSize', wPtr, params.text.size);
Screen('TextColor', wPtr, params.text.color);
Screen('TextBackgroundColor',wPtr, params.text.bkColor );

if recal
      Screen('DrawText', wPtr, recalibrate, params.screen.centerPix(1)-450, params.screen.centerPix(2)-150);
else  
Screen('DrawText', wPtr, instruct, params.screen.centerPix(1)-400, params.screen.centerPix(2)-150);
Screen('DrawText', wPtr, start, params.screen.centerPix(1)-250, params.screen.centerPix(2)+150);
end  
Screen('Flip', wPtr);

keyIsDown = 0;
while (~keyIsDown)
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(KbName('Space')),  keyIsDown = 1; break; else keyIsDown =0;  end
   
end