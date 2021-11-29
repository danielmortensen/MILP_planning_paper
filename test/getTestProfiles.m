function [p0, p1, p2] = getTestProfiles(soc)
    minSoc = 50;
    nBus = 2;
    nCharger = 2;
    if nargin == 1
        soc = ones([nBus,1])*soc;
    else
        soc = [80; 80];
    end
    % create schedules
    schedule0 = zeros([2,5]);
    schedule0(:,2:end - 1) = 1;
    schedule2 = schedule0;
    schedule1 = zeros([2,7]);
    schedule1(:,2:3) = 1; schedule1(:,5:6) = 1;
    
    % define first fleet profile
    fleetProfile0.schedule = schedule0;
    fleetProfile0.scheduleType = 2;
    fleetProfile0.soc = soc;
    fleetProfile0.nGroup = 2;
    fleetProfile0.nTime = 5;
    fleetProfile0.nCharge = 4;
    fleetProfile0.nSoc = 6;
    fleetProfile0.discharge = zeros([2,1]);
    fleetProfile0.nBusSoc = [0, 3];
    fleetProfile0.nBusDSoc = [0, 2];
    fleetProfile0.tStart = 0;
    fleetProfile0.tEnd = 4;
    fleetProfile0.nBus = 2;
    fleetProfile0.isOnPeak = [1, 1, 0, 0, 0];
    
    % define second fleet profile
    fleetProfile1.schedule = schedule1;
    fleetProfile1.scheduleType = 1;
    fleetProfile1.soc = soc;
    fleetProfile1.nGroup = 4;
    fleetProfile1.nTime = 7;
    fleetProfile1.nSoc = 8;
    fleetProfile1.nCharge = 4;
    fleetProfile1.discharge = [20, 20];
    fleetProfile1.nBusSoc = [0, 4];
    fleetProfile1.nBusDSoc = [0, 2];
    fleetProfile1.tStart = 0;
    fleetProfile1.tEnd = 6;
    fleetProfile1.nBus = 2;
    fleetProfile1.isOnPeak = [1 1 1 1 0 0 0];
    
    % define third fleet profile
    fleetProfile2.schedule = schedule2;
    fleetProfile2.scheduleType = 2;
    fleetProfile2.soc = soc;
    fleetProfile2.nGroup = 2;
    fleetProfile2.nTime = 5;
    fleetProfile2.nSoc = 6;
    fleetProfile2.nCharge = 4;
    fleetProfile2.discharge = [0, 0];
    fleetProfile2.nBusSoc = [0, 3];
    fleetProfile2.nBusDSoc = [0, 2];
    fleetProfile2.tStart = 0;
    fleetProfile2.tEnd = 4;
    fleetProfile2.nBus = 2;    
    fleetProfile2.isOnPeak = [0 0 0 0 0];
    
    % define base profile
    pBase.nBus = 2;
    pBase.minimization = 'demand'; % 'demand', 'consumption'
    pBase.minSoc = minSoc;
    pBase.dTime = 5;
    pBase.fLoadProfile = '../data/externalLoad.csv';
    
    
    % package variables
    p0.tStart = 0;
    p0.tEnd = 4;
    p0.nBus = 2;
    p0.fleetProfile = fleetProfile0;
    p0.base = pBase;
    p0.nCharger = nBus;
    p0.syncTime = 1;
    p0.scheduleType = 2;
    
    p1.tStart = 0;
    p1.tEnd = 6;
    p1.nBus = nBus;
    p1.fleetProfile = fleetProfile1;
    p1.base = pBase;
    p1.nCharger = nCharger;
    p1.syncTime = 1;
    p1.scheduleType = 1;
    
    p2.tStart = 0;
    p2.tEnd = 4;
    p2.nBus = nBus;
    p2.fleetProfile = fleetProfile2;
    p2.base = pBase;
    p2.nCharger = nBus;
    p2.syncTime = 1;
    p2.scheduleType = 2;      
end
