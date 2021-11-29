% test scenario with
% - 2 charger
% - 2 bus
% - multirate rate, nRate = 3;
% - day/night charging
% - maximum charge
function [G, Const, solution] = getScenario7()
addpath('../');
initialSoc = 80;
Scen = getScenario('startBusSocAt',80,'nNightChargeRate',1,...
                   'nDayChargeRate',3);
Const = getConstant(Scen);
[p0, p1, p2] = getTestProfiles(initialSoc);
G0 = formGraph(p0, Const);
G1 = formGraph(p1, Const);
G2 = formGraph(p2, Const);
GList = [G0, G1, G2];
G = combineModels(GList, Const);
solution = getNoChargeSolution(initialSoc, Const,p1.base.dTime);
end

function solution = getNoChargeSolution(initialSoc, Const, tDelta)
[soc, dsoc] = computeTestSoc(initialSoc, Const, tDelta);
nNightRate = numel(Const.charge.R_NIGHT);
nDayRate = numel(Const.charge.R_DAY);
nightEdge = [1 1 0 0 1 0 0 1];
dayEdge = [1 0 0 1 0 0 1 1 0 0 1 0 0 1];
nightEdges = [zeros([1,4]), nightEdge, nightEdge];
dayEdges = [zeros([1,6]), dayEdge, dayEdge];
nightDemand1 = sum(dsoc([1,2,3,4]))*4;
nightDemand2 = sum(dsoc([17, 18, 19, 20]))*4;
dayDemand = sum(dsoc([10,16]))*4;
demand = max([dayDemand, nightDemand1, nightDemand2]);
demandOnPeak = sum(dsoc([7,13]))*4;
idx1 = 4*nNightRate;
idx2 = idx1 + 4*nDayRate;
idx3 = idx2 + 4*nNightRate;
solution = [soc(1:6),  dsoc(1:idx1), nightEdges,...
            soc(7:14), dsoc(idx1 + 1:idx2), dayEdges,...
            soc(15:20),dsoc(idx2 + 1:idx3),nightEdges,...
            demand, demandOnPeak]';
end

function [soc, dsoc] = computeTestSoc(initialSoc, Const, tDelta)
discharge = 20;
maxCharge = 100;
nDayRate = numel(Const.charge.R_DAY);
nNightRate = numel(Const.charge.R_NIGHT);
[nightRate, nightIdx] = min(Const.charge.R_NIGHT);
[dayRate, dayIdx] = min(Const.charge.R_DAY);
aBarNight = exp(tDelta*nightRate);
aBarDay = exp(tDelta*dayRate);
soc = zeros([1,20]);
dsoc = zeros([1,4*nNightRate + 4*nDayRate + 4*nNightRate]);
soc([1,4]) = initialSoc;
dsoc([nightIdx, 2*nNightRate + nightIdx]) = (1 - aBarNight)*(maxCharge - soc([1,4]));
soc([2,5]) = soc([1,4]) + dsoc([nightIdx, 2*nNightRate + nightIdx]);
dsoc([nNightRate + nightIdx, 3*nNightRate + nightIdx]) = (1 - aBarNight)*(maxCharge - soc([2,5]));
soc([3,6]) = soc([2,5]) + dsoc([nNightRate + nightIdx, 3*nNightRate + nightIdx]);
soc([7, 11]) = soc([3, 6]); nightIdx1 = 4*nNightRate;
dsoc([nightIdx1 + dayIdx, nightIdx1 + nDayRate*2 + dayIdx]) = (1 - aBarDay)*(maxCharge - soc([7,11]));
soc([8, 12]) = soc([7, 11]) + dsoc([nightIdx1 + dayIdx, nightIdx1 + nDayRate*2 + dayIdx]);
soc([9, 13]) = soc([8, 12]) - discharge;
dsoc([nightIdx1 + nDayRate + dayIdx, nightIdx1 + nDayRate*3 + dayIdx]) = (1 - aBarDay)*(maxCharge - soc([9, 13]));
soc([10, 14]) = soc([9, 13]) + dsoc([nightIdx1 + nDayRate + dayIdx, nightIdx1 + nDayRate*3 + dayIdx]);
dayIdx1 = nightIdx1 + nDayRate*4;
soc([15, 18]) = soc([10, 14]);
dsoc([dayIdx1 + nightIdx, dayIdx1 + 2*nNightRate + nightIdx]) = (1 - aBarNight)*(maxCharge - soc([15,18]));
soc([16, 19]) = soc([15,18]) + dsoc([dayIdx1 + nightIdx, dayIdx1 + 2*nNightRate + nightIdx]);
dsoc([dayIdx1 + nNightRate + nightIdx, dayIdx1 + 3*nNightRate + nightIdx]) = (1 - aBarNight)*(maxCharge - soc([16,19]));
soc([17, 20]) = soc([16, 19]) + dsoc([dayIdx1 + nNightRate + nightIdx, dayIdx1 + 3*nNightRate + nightIdx]);
end
