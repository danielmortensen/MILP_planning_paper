addpath('optimization/');
addpath('graph/');
addpath('utility/');
addpath('optimization/');
addpath('visualization/');
addpath('/opt/gurobi912/linux64/matlab/');
close all;
fData = '/home/daniel/solveSchedule/data/';
doAllTest = true;
nBus = 5;
nCharger = 5;

if doAllTest
%% Define Scenarios
% 36 bus, 5 charge rate, 6 overhead charger MinSchedule8
scenario1 = getScenario('fExternalLoad','originalTpss1Day.csv',...
    'nBus',nBus, 'nOverheadCharger',nCharger, 'fData',fData);

% 36 bus 5 charge rate, 6 overhead charger baseline
scenario2 = getScenario('fExternalLoad','originalTpss1Day.csv',...
    'minObjective','baseline','nBus',nBus, 'nOverheadCharger',nCharger, 'fData',fData);

% 36 bus, 1 charge rate, 6 overhead charger MinSchedule8
scenario3 = getScenario('fExternalLoad','originalTpss1Day.csv',...
    'nBus',nBus,'nDayChargeRate',1,'nOverheadCharger',nCharger, 'fData',fData);

% 36 bus 1 charge rate, 6 overhead charger baseline
scenario4 = getScenario('fExternalLoad','originalTpss1Day.csv',...
    'minObjective','baseline','nBus',nBus,'nDayChargeRate',1,...
    'nOverheadCharger',nCharger, 'fData',fData);

%% Run Scenarios
result1 = runSimulation(scenario1, '5_Bus_5_ChargeRate_5_Overhead_MinSchedule8');
result2 = runSimulation(scenario2, '5_Bus_5_ChargeRate_5_Overhead_Baseline');
result3 = runSimulation(scenario3, '5_Bus_1_ChargeRate_5_Overhead_MinSchedule8');
result4 = runSimulation(scenario4, '5_Bus_1_ChargeRate_5_Overhead_Baseline');
else
    scenario1 = getScenario('fExternalLoad','originalTpss1Day.csv',...
    'nBus',5, 'nOverheadCharger',6, 'nDayChargeRate',1,'fData',fData);
    result1 = runSimulation(scenario1, '5Bus1ChargeRate6OverheadMinSchedule8');
end



function [result, Const, G] = runSimulation(scenario, simId)
[result, Const, G] = solveScenario(scenario);
if strcmp(scenario.minObjective,'baseline')
    [result.x, G] = convertToSchedule8(result.x, G, Const);
end
save(simId + ".mat",'G','result','Const');
makePieChart(G, result.x, simId);
makeSocChart(G, result.x, Const, false, simId);
makeGraphPlot(G, result.x, Const, simId);
makeTotalPowerPlot(G, result.x, simId);
makePowerPlot(G, result.x, simId);
makeTotalEnergyPlot(G, result.x, Const, simId);
end

function [result, G] = convertToSchedule8(result, G, Const)
facilitiesA = toSparse(G.Constraint.demand.A,G.param.nSolution);
facilitiesA(:,end-1:end) = 0;
facilities = max(facilitiesA*result - G.Constraint.demand.b);

onPeakA = toSparse(G.Constraint.demandOnPeak.A,G.param.nSolution);
onPeakA(:,end-1:end) = 0;
onPeak = max(onPeakA*result - G.Constraint.demandOnPeak.b);

result(end - 1) = facilities;
result(end) = onPeak;

G.param.base.minimization = 'MinSchedule8';
G.Constraint.objective = getObjective(G,Const);
end












