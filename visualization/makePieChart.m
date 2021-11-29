function makePieChart(G, result, id)
daysPerMonth = 365/12;
onPeakEnergyCost = 0.058282; %dollars
offPeakEnergyCost = 0.029624; %dollars

% compute non-peak energy cost
energyExt = G.extern.load;
energyExt(energyExt < 0) = 0; % assume they don't get any kickback for negative power.
onPeakIdx = G.extern.time > 15*60 & G.extern.time < 22*60;
offPeakIdx = ~onPeakIdx;
energyOnPeak = sum(energyExt(onPeakIdx));
energyOffPeak = sum(energyExt(offPeakIdx));
costExtern = (energyOnPeak*onPeakEnergyCost + ...
              energyOffPeak*offPeakEnergyCost)*daysPerMonth;

% compute energy consumed by buses
energyBus = G.Constraint.objective;
energyBus(G.param.yFacilitiesIdx) = 0;
energyBus(G.param.yOnPeakDemandIdx) = 0;
costBus = energyBus'*result;

% compute price for total energy used
costEnergyTotal = costExtern + costBus;
energyLabel = "Energy Cost: " + formatValueInDollars(costEnergyTotal);

% compute peak demand cost
demandPeak = G.Constraint.objective(G.param.yOnPeakDemandIdx)*result(G.param.yOnPeakDemandIdx);
demandLabel = "Peak Demand Cost: " + formatValueInDollars(demandPeak);

% compute facilities cost
demandFacilities = G.Constraint.objective(G.param.yFacilitiesIdx)*result(G.param.yFacilitiesIdx);
facilitiesLabel = "Total Demand (Facilities) Charge: " + formatValueInDollars(demandFacilities);

% plot results
labels = {energyLabel, demandLabel, facilitiesLabel};
costs = [costEnergyTotal, demandPeak, demandFacilities];
figure; pie(costs,labels);
if nargin == 2
titleLabel = "Total Estimated Monthly Cost: " + formatValueInDollars(sum(costs));
else
    titleLabel = "Total Estimated Monthly Cost: " +...
        formatValueInDollars(sum(costs)) + " for " + string(id);
end
title(titleLabel);
end
