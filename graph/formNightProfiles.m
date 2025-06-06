function [p0, p2] = formNightProfiles(GDay, base, Const)
nBus = GDay.param.fleetProfile.nBus;
tStart = GDay.param.fleetProfile.tStart;
tEnd = GDay.param.fleetProfile.tEnd;
dTime = GDay.param.base.dTime;

fleetProfile0 = getNightFleetProfile(nBus, 0, tStart, dTime, Const);
fleetProfile1 = getNightFleetProfile(nBus, tEnd, 1440, dTime, Const);
p0.nBus = nBus;
p0.tStart = 0;
p0.tEnd = tStart - 1;
p0.dTime = dTime;
p0.fleetProfile = fleetProfile0;
p0.base = base;
p0.speed = 0;
p0.nCharger = nBus;
p0.dDischarge = 0;
p0.syncTime = 1;
p0.normPeak = 0;
p0.iInitialNode = 1;
p0.iInitialEdge = 1;
p0.scheduleType = Const.schedule.type.NIGHT;
p0.iInitialNode = 1;
p0.iInitialEdge = 1;

p2.nBus = nBus;
p2.tStart = tEnd + 1;
p2.tEnd = 1440;
p2.dTime = dTime;
p2.fleetProfile = fleetProfile1;
p2.base = base;
p2.speed = 0;
p2.nCharger = nBus;
p2.dDischarge = 0;
p2.syncTime = 1;
p2.normPeak = 0;
p2.iInitialNode = 1;
p2.iInitialEdge = 1;
p2.scheduleType = Const.schedule.type.NIGHT;
end
