addpath('optimization/');
addpath('graph/');
addpath('utility/');
addpath('optimization/');
addpath('visualization/');
addpath('/opt/gurobi912/linux64/matlab/');
close all;

% % find best case scenario for stress test scenario
% scenario = getScenario('fExternalLoad','originalTpss1Day.csv','nBus',36,...
%     'nOverheadCharger',6);
% runSimulation(scenario, 'Optimal Solution');

% find worst case scenario
scenario = getScenario('fExternalLoad','originalTpss1Day.csv','nBus',36,...
    'nOverheadCharger',6,'minObjective','MaxSchedule8','disoptimality',500000);
[result, Const, G] = runSimulation(scenario, 'Disoptimal: 500,000');

% find worst case scenario
% scenario = getScenario('fExternalLoad','originalTpss1Day.csv',...
%     'minObjective','flatConsumption','nBus',36,'nDayChargeRate',1,...
%     'nOverheadCharger',6);
% result = runSimulation(scenario, 'Previous Solution');

function [result, Const, G] = runSimulation(scenario, simId)
[result, Const, G] = solveScenario(scenario);
if ~contains(scenario.minObjective,'Schedule8')
    [result.x, G] = convertToSchedule8(result.x, G, Const);
end
makePlots(G, result, Const, simId);
end
function makePlots(G, result, Const, titleId)
makePieChart(G, result.x, titleId);
makeSocChart(G, result.x, Const, false, titleId);
makeGraphPlot(G, result.x, Const, titleId);
makeTotalPowerPlot(G, result.x, titleId);
makePowerPlot(G, result.x, titleId);
makeTotalEnergyPlot(G, result.x, Const, titleId);
end

function [result, G] = convertToSchedule8(result, G, Const)
facilitiesA = toSparse(G.Constraint.demand.A,G.param.nSolution);
facilitiesA(:,G.param.yFacilitiesIdx) = 0;
facilities = max(facilitiesA*result - G.Constraint.demand.b);

onPeakA = toSparse(G.Constraint.demandOnPeak.A,G.param.nSolution);
onPeakA(:,G.param.yOnPeakDemandIdx) = 0;
onPeak = max(onPeakA*result - G.Constraint.demandOnPeak.b);

result(G.param.yFacilitiesIdx) = facilities;
result(G.param.yOnPeakDemandIdx) = onPeak;

G.param.base.minimization = 'Schedule8';
G.Constraint.objective = getObjective(G,Const);
end












