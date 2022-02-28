addpath('optimization/');
addpath('graph/');
addpath('utility/');
addpath('optimization/');
addpath('visualization/');
%addpath('/opt/gurobi912/linux64/matlab/');
close all;
...fData = '/home/daniel/solveSchedule/data/';
fData = '\\wsl.localhost\Ubuntu\home\dmortensen\MILP_planning_paper\data';
doAllTest = true;
nBus = 5;
nCharger = 6;

if doAllTest
%% Define Scenarios
% 5 bus, 1 charge rate, 2 overhead charger MinSchedule8
scenario1 = getScenario('fExternalLoad','originalTpss1Day.csv',...
    'nBus',5,'nDayChargeRate',5,'nOverheadCharger',5, 'fData',fData);

% 5 bus 1 charge rate, 3 overhead charger baseline
scenario2 = getScenario('fExternalLoad','originalTpss1Day.csv',...
    'nBus',10,'nDayChargeRate',1,'nOverheadCharger',1, 'fData',fData);

% 5 bus, 1 charge rate, 4 overhead charger MinSchedule8
scenario3 = getScenario('fExternalLoad','originalTpss1Day.csv',...
    'nBus',11,'nDayChargeRate',1,'nOverheadCharger',1, 'fData',fData);

% 36 bus 1 charge rate, 6 overhead charger baseline
scenario4 = getScenario('fExternalLoad','originalTpss1Day.csv',...
    'minObjective','baseline','nBus',nBus,'nDayChargeRate',1,...
    'nOverheadCharger',nCharger, 'fData',fData);

%% Run Scenarios
result1 = runSimulation(scenario1, '9_Bus_1_ChargeRate_1_Overhead_MinSchedule8');
result2 = runSimulation(scenario2, '10_Bus_1_ChargeRate_1_Overhead_MinSchedule8');
result3 = runSimulation(scenario3, '11_Bus_1_ChargeRate_1_Overhead_MinSchedule8');
result4 = runSimulation(scenario4, '5_Bus_1_ChargeRate_1_Overhead_Baseline');
else
    scenario1 = getScenario('fExternalLoad','originalTpss1Day.csv',...
    'nBus',5, 'nOverheadCharger',6, 'nDayChargeRate',1,'fData',fData);
    result1 = runSimulation(scenario1, '5Bus1ChargeRate6OverheadMinSchedule8');
end
















