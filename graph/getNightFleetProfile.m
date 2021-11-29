
function p = getNightFleetProfile(nBus, tStart, tEnd, dTime, Const)
nTime = round((tEnd - tStart)/dTime);
times = tStart + (0:nTime - 1)*dTime;
isOnPeak = times > 900 & times < 1320;
schedule = ones([nBus,nTime]);
schedule(:,1) = 0;
schedule(:,end) = 0;
p.schedule = schedule;
p.scheduleType = Const.schedule.type.NIGHT;
p.soc = ones([nBus,1])*80;
p.nGroup = nBus;
p.nTime = nTime;
p.nSoc = nBus*(nTime - 2);
p.nCharge = nBus*(nTime - 3);
p.discharge = zeros([nBus,1]);
p.nBusSoc = ((0:nBus - 1)*(nTime - 2))';
p.nBusDSoc = ((0:nBus - 1)*(nTime - 3))';
p.tStart = tStart;
p.tEnd = tEnd;
p.nBus = nBus;
p.isOnPeak = isOnPeak;
end
