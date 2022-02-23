function makePowerPlot(G, result, id, latexFilePath)
% get average power for buses
busPowerSelect = toSparse(G.Constraint.demand.A, G.param.nSolution);
busPowerSelect(:,end - 1:end) = 0;
meanBusPower = busPowerSelect*result;

% get average power for uncontrolled loads
loadPower = -G.Constraint.demand.b;

% plot values
figure; hold on; 
plot(meanBusPower);
plot(loadPower);

% add shading
maxVal = max([meanBusPower(:); loadPower(:)]);
minVal = min([meanBusPower(:); loadPower(:)]);
dTime = G.param.base.dTime;
addOnPeakShading(gca, maxVal, minVal, dTime);

% add time for x axis
nTime = G.param.nTime;
addTimeAxis(gca,nTime, 24*60);

% add legend
legend('Average Bus Load', 'Average Uncontrolled Load', 'On Peak Time Interval');
titleStr = "Load Components";
if nargin == 3
    titleStr = titleStr + " for " + string(id);
end
title(titleStr);
xlabel('time'); ylabel('Average kW');
if nargin == 4
    datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');   
    time = datetime(0,0,0,0,0,(0:dTime*60:60*60*24 - 1))';
    data = table(meanBusPower, loadPower, time);
    writetable(data, latexFilePath,'Delimiter',',');
end

end
