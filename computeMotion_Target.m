function [allPosPix]= computeMotion_Target(trialAngle,dotCohSD)
global params; 
% Compute motion direction for coherent motion
dxdy = zeros(params.dots.num,2);

numDots = params.dots.num;

if cue_OR_target == 1 %target
    trialAngle_AllDots =  normrnd(trialAngle,dotCohSD,numDots,1);
%     dotColor = params.stim.color;
end

dxdy_dirc 	= params.stim.speedDegPerSec .* (1/params.screenVar.monRefresh) .* [cos(pi*trialAngle_AllDots/180.0) sin(pi*trialAngle_AllDots/180.0)];

dxdy(:,1) =  dxdy_dirc(:,1).*params.screenVar.degratioX;
dxdy(:,2) =  dxdy_dirc(:,2).*params.screenVar.degratioY;


% % Calculate which dots will be moving coherently to direction trial angle
% % and which not
% L = rand(numDots,1) < dotCohSD;
% dxdy(L,:) = dxdy_dirc(L,:); 
% dircs = repmat(trialAngle,numDots,1);
% if sum(~L) > 0, dxdy(~L,:) = dxdy_rand(~L,:); end
% dircs(~L) = randDirc(~L);

%Initial random dot position
% randAnglesRad = pi*2*(rand(numDots,1)); randAmps = sqrt(params.stim.radiusDeg*(rand(numDots,1)));
% [allPos.x,allPos.y] = pol2cart(randAnglesRad,randAmps);
q = rand(numDots,1)*pi*2; 
r = (rand(numDots,1)).^0.5;
allPos.x = r.*params.stim.radiusDeg.*cos(q);
allPos.y = r.*params.stim.radiusDeg.*sin(q);

%Compute motin according to direction, wrap if necessary and randomly
%re-assign postions if limited lifetime for dots
for i = 2:params.stim.durInFrames
    allPos.x(:,i) = allPos.x(:,i-1)+dxdy(:,1);
    allPos.y(:,i) = allPos.y(:,i-1)+dxdy(:,2);
    wrap = abs(allPos.x(:,i))> params.stim.radiusDeg | abs(allPos.y(:,i))>params.stim.radiusDeg; 
    if sum(wrap)>0
        allPos.x(wrap,i) = -allPos.x(wrap,i);
        allPos.y(wrap,i) = -allPos.y(wrap,i);
    end  
    if params.stim.lifetime
        jump = rand(numDots,1)<params.stim.limitLifetime;
        if sum(jump)>0
            q = rand(sum(jump),1)*pi*2; 
            r = (rand(sum(jump),1)).^0.5;
            allPos.x(jump,i) = r.*params.stim.radiusDeg.*cos(q);
            allPos.y(jump,i) = r.*params.stim.radiusDeg.*sin(q);
        end
    end
end
%Transform to pixels from visual degrees
allPosPix.x = floor(params.screenVar.ppd .* allPos.x)+ params.screenVar.centerPix(1)-params.stim.apertureCenterPix(1); 
allPosPix.y = floor(params.screenVar.ppd .* allPos.y)+ params.screenVar.centerPix(2)-params.stim.apertureCenterPix(2);	