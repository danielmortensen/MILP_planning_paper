function comparisonCost(maxResult, minResult, tikzFilePath)


figure; 
cost1 = computeCost(maxResult.G, maxResult.result.x);
cost2 = computeCost(minResult.G, minResult.result.x);
labels = categorical({'Energy Charge','On Peak Demand', 'Facilities Demand'});
bar(labels,[cost1; cost2]');
legend('Worst Case','Optimized Case','Location','northwest');
ylabel('Kwh'); title('Monthly Breakdown');

if nargin == 3
    type = ["Energy";"Facilities Power";"On-Peak Power"];
    baseline = cost1'; 
    optimized = cost2';    
    data = table(type,baseline, optimized);
    % ../../paper/media/costComparison.csv
    writetable(data, tikzFilePath,'Delimiter',',');
end
end

function output = computeCost(G, result)
daysPerMonth = 365/12;
onPeakEnergyCost = 0.058282; %dollars
offPeakEnergyCost = 0.029624; %dollars
if ~isfield(G.param,'yFacilitiesIdx')
    facilitiesIdx = numel(result) - 1;
    onPeakDemandIdx = numel(result);
else
    facilitiesIdx = G.param.yFacilitiesIdx;
    onPeakDemandIdx = G.param.yOnPeakDemandIdx;
end

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
energyBus([facilitiesIdx onPeakDemandIdx]) = 0;
costBus = energyBus'*result;

% compute price for total energy used
costEnergyTotal = costExtern + costBus;

% compute peak demand cost
demandPeak = G.Constraint.objective(onPeakDemandIdx)*result(onPeakDemandIdx);

% compute facilities cost
demandFacilities = G.Constraint.objective(facilitiesIdx)*result(facilitiesIdx);

% concatentate
output = [costEnergyTotal, demandPeak, demandFacilities];


end