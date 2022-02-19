function makeTotalPowerPlot(G, result, id)

% compute values for facilities charge over time
busFacilitiesSelect = toSparse(G.Constraint.demand.A, G.param.nSolution);
busFacilitiesSelect(:,end - 1) = 0;
demandFacilities = -busFacilitiesSelect*result - G.Constraint.demand.b;
maxFacilities = result(end - 1);

% compute values for on-peak demand charge over time
busDemandSelect = toSparse(G.Constraint.demandOnPeak.A, G.param.nSolution);
busDemandSelect(:,end) = 0;
demandOnPeak = zeros([G.param.nTime,1]);
isOnPeak = logical(G.param.isOnPeak);
demandOnPeak(isOnPeak) = -busDemandSelect*result - G.Constraint.demandOnPeak.b;
maxOnPeak = result(end);

% plot values
figure; hold on; 
plot(demandFacilities);
plot(demandOnPeak);
yline(maxFacilities,'r');
yline(maxOnPeak,'--c');

% add on peak shading
maxVal = max(maxOnPeak, maxFacilities);
minVal = min(demandFacilities);
dTime = G.param.base.dTime;
addOnPeakShading(gca,maxVal, minVal, dTime);

% update x axis 
nTime = G.param.nTime;
addTimeAxis(gca,nTime,24*60);

% add legend values
legend('Facilities','On Peak', 'Max Facilities', 'Max On Peak',...
       'On Peak Time Interval','Location','southwest');
   
titleStr = "Total Required Power";
if nargin == 3
    titleStr = titleStr + " for " + id;
end
title(titleStr);
end
