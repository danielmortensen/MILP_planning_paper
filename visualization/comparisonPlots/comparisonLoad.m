function comparisonLoad(maxResult, minResult)
figure; hold on; 
dTime = maxResult.G.param.base.dTime;
[max1Val, min1Val] = plotSingleComparison(maxResult.G, maxResult.result.x, true);
[max2Val, min2Val] = plotSingleComparison(minResult.G, minResult.result.x, false);
addOnPeakShading(gca,max([max1Val, max2Val]), min([min1Val, min2Val]), dTime);

% update x axis 
nTime = maxResult.G.param.nTime;
addTimeAxis(gca,nTime,24*60);
legend('Unoptimized Demand: bus','Unoptimized Demand: total',...
       'Unoptimized Facilities','Unoptimized On-Peak Demand',...
       'Optimized Demand: bus','Optimized Demand: total',...
       'Optimized Facilities','Optimized On-Peak Demand');
end



function [maxVal, minVal] = plotSingleComparison(G, result, makeDashed)
% compute values for facilities charge over time
if isfield(G.param,'yFacilitiesIdx')
    facilitiesIdx = G.param.yFacilitiesIdx;
    onPeakDemandIdx = G.param.yOnPeakDemandIdx;
else
    facilitiesIdx = numel(result) - 1;
    onPeakDemandIdx = numel(result);
end

busFacilitiesSelect = toSparse(G.Constraint.demand.A, G.param.nSolution);
busFacilitiesSelect(:,facilitiesIdx) = 0;
busFacilitiesSelect(:,onPeakDemandIdx) = 0;
busFacilitiesSelect = busFacilitiesSelect(1:G.param.nTime,:);
bFacilities = G.Constraint.demand.b(1:G.param.nTime,:);
busDemand = busFacilitiesSelect*result;
demandFacilities = busDemand - bFacilities;
maxFacilities = result(facilitiesIdx);

% compute values for on-peak demand charge over time
busDemandSelect = toSparse(G.Constraint.demandOnPeak.A, G.param.nSolution);
busDemandSelect(:,onPeakDemandIdx) = 0;
busDemandSelect(:,facilitiesIdx) = 0;
busDemandSelect = busDemandSelect(1:sum(G.param.isOnPeak),:);
demandB = G.Constraint.demandOnPeak.b(1:sum(G.param.isOnPeak));
demandOnPeak = zeros([G.param.nTime,1]);
isOnPeak = logical(G.param.isOnPeak);
demandOnPeak(isOnPeak) = -busDemandSelect*result - demandB;
maxOnPeak = result(onPeakDemandIdx);

% plot values
if makeDashed
plot(demandFacilities,'--');
plot(busDemand,'--');
else
plot(demandFacilities);
plot(busDemand);
end    
%plot(demandOnPeak);
yline(maxFacilities,'r');
yline(maxOnPeak,'--c');

% add on peak shading
maxVal = max(demandFacilities);
minVal = min(demandFacilities);

end