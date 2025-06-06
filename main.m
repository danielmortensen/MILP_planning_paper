addpath('optimization/');
addpath('graph/');
addpath('utility/');
addpath('optimization/');
addpath('visualization/');
close all;
...fData = '\\wsl.localhost\Ubuntu\home\dmortensen\MILP_planning_paper\data';
...fData = 'data/';
fData = '/home/daniel/Research/paper2/data_management/data/';
fExternalLoad = fullfile('processed_tpss','TPSS_Cov15.mat'); ...'originalTpss1Day.csv';
fRoute = fullfile('processed','routesTable.csv');
nBus = 5;
nCharger = 1;

% Define Scenarios
scenario1 = getScenario('fExternalLoad',fExternalLoad,...
    'nBus',nBus,'nDayChargeRate',1,'nOverheadCharger',nCharger,...
    'minObjective','minSchedule8','fData',fData,'dTime',15,'fRoute',fRoute,'chargeAtNight',false);

% run Scenarios
saveFolder = 'resultsOther';
saveFile = '5_Bus_1_ChargeRate_1_Overhead_minSchedule8_dTime_15';
savePath = fullfile(saveFolder, saveFile);
result1 = runSimulation(scenario1, savePath);


















