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

% format route informaiton
try
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
    schedule(:,1) = 0;
    schedule(:, end) = 0;
    nTime = size(schedule,2);
    nSoc = sum(schedule,'all');
    nBusSoc = sum(schedule,2); nBusSoc = [0; nBusSoc];
    nBusDSoc = (sum(schedule,2) - nBusGroup); nBusDSoc = [0; nBusDSoc];
    nBusSoc = cumsum(nBusSoc); nBusSoc(end) = [];
    nBusDSoc = cumsum(nBusDSoc); nBusDSoc(end) = [];
    nCharge = nSoc - nGroup;
catch
    routeCsv = readtable(fileId);
    routes = sortrows(routeCsv,'nRoute','descend');
    nBus = busLimit;

    % get nBus worth of route data
    simRoutes = routes(1:nBus,:);
    nRoute = table2array(simRoutes(:,end-1));
    simRoutes = simRoutes(:,1:end-3);
    simRoutes = table2array(simRoutes);
    tArrival = simRoutes(:,1:3:end);
    tDepart = simRoutes(:,2:3:end);
    dSoc = -simRoutes(:,3:3:end);
    tStart = min(tDepart(:))/60; % convert to minutes
    tEnd = max(tArrival(:))/60; % convert to minutes;
    nTime = floor((tEnd - tStart)/tDelta) + 2;
    times = (0:nTime - 1)*tDelta + tStart - tDelta;
    
    % format availability and discharge information
    schedule = ones([nBus, nTime]);    
    discharge = zeros([nBus, 1]);
    for iBus = 1:nBus
        for iRoute = 1:nRoute(iBus) - 1
            start = tDepart(iBus,iRoute)/60;
            final = tArrival(iBus,iRoute + 1)/60;
            if isnan(start)
                continue;
            end
            startIdx = int64(floor((start - tStart)/tDelta) + 2);
            finalIdx = int64(floor((final - tStart)/tDelta) + 1);
            schedule(iBus,startIdx:finalIdx) = 0;
        end
        discharge(iBus) = dSoc(iBus,iRoute);
    end
    schedule(:,1) = 0;
    schedule(:, end) = 0;

    % compute on vs off peak times
    isOnPeak = times > 900 & times < 1320;
    soc = ones([nBus,1])*80;
    nBusGroup = sum(~isnan(tArrival),2);
    nGroup = sum(nBusGroup);

    % compute quantities of variables
    nTime = size(schedule,2);
    nSoc = sum(schedule,'all');
    nBusSoc = sum(schedule,2); nBusSoc = [0; nBusSoc];
    nBusDSoc = (sum(schedule,2) - nBusGroup); nBusDSoc = [0; nBusDSoc];
    nBusSoc = cumsum(nBusSoc); nBusSoc(end) = [];
    nBusDSoc = cumsum(nBusDSoc); nBusDSoc(end) = [];
    nCharge = nSoc - nGroup;
end

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
