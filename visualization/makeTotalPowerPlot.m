function makeTotalPowerPlot(G, result, id)

% compute values for facilities charge over time
busFacilitiesSelect = toSparse(G.Constraint.demand.A, G.param.nSolution);
busFacilitiesSelect(:,G.param.yFacilitiesIdx) = 0;
busFacilitiesSelect(:,G.param.yOnPeakDemandIdx) = 0;
busFacilitiesSelect = busFacilitiesSelect(1:G.param.nTime,:);
bFacilities = G.Constraint.demand.b(1:G.param.nTime);
demandFacilities = -busFacilitiesSelect*result - bFacilities;
maxFacilities = result(G.param.yFacilitiesIdx);

% compute values for on-peak demand charge over time
busDemandSelect = toSparse(G.Constraint.demandOnPeak.A, G.param.nSolution);
busDemandSelect(:,G.param.yOnPeakDemandIdx) = 0;

busDemandSelect = busDemandSelect(1:sum(G.param.isOnPeak),:);
demandB = G.Constraint.demandOnPeak.b(1:sum(G.param.isOnPeak));
demandOnPeak = zeros([G.param.nTime,1]);
isOnPeak = logical(G.param.isOnPeak);
demandOnPeak(isOnPeak) = -busDemandSelect*result - demandB;
maxOnPeak = result(G.param.yOnPeakDemandIdx);

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
