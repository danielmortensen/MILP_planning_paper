function Scene = getScenario(varargin)
P = inputParser;
addParameter(P, 'dTime',5);
addParameter(P, 'chargeAtNight',true);
addParameter(P, 'maxBatteryCharge',100);
addParameter(P, 'nNightChargeRate', 1);
addParameter(P, 'nDayChargeRate',4);
addParameter(P, 'nightChargeRates',[]);
addParameter(P, 'dayChargeRates',[]);
addParameter(P, 'fData','/home/daniel/backup/PycharmProjects/intermodalHubEnvironment-v2/planning/solveSchedule/data/');
addParameter(P, 'fExternalLoad','externalLoad.csv');
addParameter(P, 'fRoute','routeProfiles.csv');
addParameter(P, 'nBus',10);
addParameter(P, 'nDepotCharger',NaN);
addParameter(P, 'nOverheadCharger',3);
addParameter(P, 'minObjective','MinCostSchedule8');
addParameter(P, 'socLowerBound',50);
addParameter(P, 'dischargeRoute','byDistance');
addParameter(P, 'startBusSocAt',80);
addParameter(P, 'provideZeroChargeOption',false);
parse(P,varargin{:});
Scene.dTime = P.Results.dTime; %in minutes
Scene.chargeAtNight = P.Results.chargeAtNight;
Scene.maxBatteryCharge = P.Results.maxBatteryCharge; %measured in kWh
Scene.nNightChargeRate = P.Results.nNightChargeRate;
Scene.nDayChargeRate = P.Results.nDayChargeRate;
if isempty(P.Results.nightChargeRates)
    Scene.nightChargeRates = getChargeRates(Scene.nNightChargeRate,'depo',...
                                            P.Results.provideZeroChargeOption);
end
if isempty(P.Results.dayChargeRates)
    Scene.dayChargeRates = getChargeRates(Scene.nDayChargeRate,'overhead',...
                                            P.Results.provideZeroChargeOption);
end
    
Scene.fData = P.Results.fData;
Scene.fExternalLoad = fullfile(Scene.fData, P.Results.fExternalLoad);
Scene.fRoute = fullfile(Scene.fData,P.Results.fRoute);
Scene.nBus = P.Results.nBus;
Scene.nDepotCharger = Scene.nBus;
Scene.nOverheadCharger = P.Results.nOverheadCharger;
Scene.minObjective = P.Results.minObjective;
Scene.socLowerBound = P.Results.socLowerBound; %in kWh
Scene.dischargeRoute = P.Results.dischargeRoute; %'byDSoc' in kWh
if numel(P.Results.startBusSocAt) == 1
    Scene.startBusSocAt = ones([Scene.nBus,1])*P.Results.startBusSocAt;
else
    Scene.startBusSocAt = P.Results.startBusSocAt;
end
end

function rates = getChargeRates(nRate, chargerType, useZero)
if strcmp(chargerType,'depo')
    if nRate == 1
        rates = -0.003;
    else
        rates = linspace(-0.003,-0.03, nRate);
    end
else
    if nRate == 1
        rates = -0.03;    
    else
        rates = linspace(-0.003,-0.03,nRate);
    end
end
if nRate > 1 && useZero
    rates(1) = -inf;
end
end