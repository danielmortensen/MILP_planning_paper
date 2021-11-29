function makePowerPlot(G, result, id)
% get average power for buses
busPowerSelect = toSparse(G.Constraint.demand.A, G.param.nSolution);
busPowerSelect = busPowerSelect(1:G.param.nTime,:);
busPowerSelect(:,G.param.yFacilitiesIdx) = 0;
busPowerSelect(:,G.param.yOnPeakDemandIdx) = 0;
meanBusPower = busPowerSelect*result;

% get average power for uncontrolled loads
loadPower = -G.Constraint.demand.b(1:G.param.nTime);

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
end
