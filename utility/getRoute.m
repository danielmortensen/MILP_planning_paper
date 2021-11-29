function rInfo = getRoute(simParams, Const)
if simParams.scheduleType == Const.schedule.type.DAY
    nRate = Const.charge.nDayRate;
else
    nRate = Const.charge.nNightRate;
end

if isfield(simParams,'fFleetProfile')
fileId = simParams.fFleetProfile;
speed = simParams.speed;
tDelta = simParams.base.dTime;
dDischarge = simParams.dDischarge;
busLimit = simParams.base.nBus;


routeCsv = readtable(fileId);
if exist('busLimit','var') && busLimit < size(routeCsv,1)
    routeCsv = routeCsv(1:busLimit,:);
end
nBus = size(routeCsv.RouteLength,1);
nRoute = size(routeCsv,2) - 3;
startTimes = table2array(routeCsv(:,3:end));
tEnd = max(startTimes(:))*60;
tStart = min(startTimes(:))*60 - 30;
nTime = floor((tEnd - tStart)/tDelta);
times = (0:nTime - 1)*tDelta + tStart;

% compute on vs off peak times
isOnPeak = times > 900 & times < 1320;

schedule = ones([nBus, nTime]);
soc = ones([nBus,1])*80;
nGroup = (size(routeCsv,2) - 2)*nBus;
nBusGroup = size(routeCsv,2) - 2;
discharge = zeros([nBus, 1]);
for iBus = 1:nBus
    for iRoute = 1:nRoute
        routeStart = table2array(routeCsv(iBus, iRoute + 2));
        startIdx = int64((routeStart*60 - tStart)/tDelta + 1);
        endIdx = int64(startIdx + (routeCsv.RouteLength(iBus)/speed)/tDelta);
        schedule(iBus,startIdx:endIdx) = 0;
    end
    discharge(iBus) = table2array(routeCsv(iBus, 2))*dDischarge;
end
%schedule(:,end + 1:end + 10) = 1;
schedule(:,1) = 0;
schedule(:, end) = 0;
nTime = size(schedule,2);
nSoc = sum(schedule,'all');
nBusSoc = sum(schedule,2); nBusSoc = [0; nBusSoc];
nBusDSoc = (sum(schedule,2) - nBusGroup); nBusDSoc = [0; nBusDSoc];
nBusSoc = cumsum(nBusSoc); nBusSoc(end) = [];
nBusDSoc = cumsum(nBusDSoc); nBusDSoc(end) = [];
nCharge = nSoc - nGroup;
rInfo.schedule = schedule;
rInfo.soc = soc;
rInfo.nGroup = nGroup;
rInfo.nTime = nTime;
rInfo.nSoc = nSoc;
rInfo.nCharge = nCharge*nRate;
rInfo.nBus = nBus;
rInfo.discharge = discharge;
rInfo.nBusSoc = nBusSoc;
rInfo.nBusDSoc = nBusDSoc*nRate;
rInfo.tStart = tStart;
rInfo.tEnd = tEnd;
rInfo.scheduleType = Const.schedule.type.DAY;
rInfo.isOnPeak = isOnPeak;
else
   rInfo = simParams.fleetProfile;
   rInfo.nBusDSoc = rInfo.nBusDSoc*nRate;
   rInfo.nCharge = rInfo.nCharge*nRate;
end
end
