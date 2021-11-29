function h = addOnPeakShading(hIn,maxVal, minVal, dTime)
cm = [0.3 0.3 0.3];
lTime = 15*60/dTime;
rTime = 22*60/dTime;
top = maxVal + 3;
bottom = minVal;
h = patch(hIn,[lTime rTime rTime lTime lTime]',...
             [bottom bottom top top bottom]',...
             cm, 'FaceAlpha',0.1, 'EdgeAlpha',0.4);
ylim([minVal,maxVal + 1]);
end
