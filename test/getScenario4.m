% test scenario with
% - 2 charger
% - 2 bus
% - single rate
% - day/night charging
% - all charge
function [G, Const, solution] = getScenario4()
addpath('../');
Scen = getScenario('startBusSocAt',80,'nNightChargeRate',1,...
                   'nDayChargeRate',1);
initialSoc = 80;
Const = getConstant(Scen);
[p0, p1, p2] = getTestProfiles(initialSoc);
G0 = formGraph(p0, Const);
G1 = formGraph(p1, Const);
G2 = formGraph(p2, Const);
GList = [G0, G1, G2];
G = combineModels(GList, Const);
solution = getNoChargeSolution(initialSoc, Const, p1.base.dTime);
end
function solution = getNoChargeSolution(initialSoc, Const, tDelta)
[soc, dsoc] = computeTestSoc(initialSoc, Const, tDelta);
nightEdge = [1 1 0 0 1 0 0 1];
dayEdge = [1 1 0 0 1 1 1 0 0 1];
nightEdges = [zeros([1,4]), nightEdge, nightEdge];
dayEdges = [zeros([1,6]), dayEdge, dayEdge];
nightDemand = sum(dsoc([1,2,3,4]))*4;
dayDemand = sum(dsoc([6,8]))*4;
demand = max(dayDemand, nightDemand);
demandOnPeak = sum(soc([5,7]))*4;
solution = [soc(1:6),  dsoc(1:4), nightEdges,...
            soc(7:14), dsoc(5:8), dayEdges,...
            soc(15:20),dsoc(9:12),nightEdges,...
            demand, demandOnPeak]';
end

function [soc, dsoc] = computeTestSoc(initialSoc, Const, tDelta)
discharge = 20;
maxCharge = 100;
dayRate = Const.charge.R_DAY;
nightRate = Const.charge.R_NIGHT;
aBarDay = exp(dayRate*tDelta);
aBarNight = exp(nightRate*tDelta);
soc = zeros([1,20]);
dsoc = zeros([1,12]);
soc([1,4]) = initialSoc;
dsoc([1,3]) = (1 - aBarNight)*(maxCharge - initialSoc);
soc([2,5]) = soc([1,4]) + dsoc([1,3]);
dsoc([2,4]) = (1 - aBarNight)*(maxCharge - soc([2,5]));
soc([3,6]) = soc([2,5]) + dsoc([2,4]);
soc([7, 11]) = soc([3, 6]);
dsoc([5, 7]) = (1 - aBarDay)*(maxCharge - soc([7, 11]));
soc([8, 12]) = soc([7, 11]) + dsoc([5, 7]);
soc([9, 13]) = soc([8, 12]) - discharge;
dsoc([6, 8]) = (1 - aBarDay)*(maxCharge - soc([9, 13]));
soc([10, 14]) = soc([9, 13]) + dsoc([6, 8]);
soc([15, 18]) = soc([10, 14]);
dsoc([9, 11]) = (1 - aBarNight)*(maxCharge - soc([15, 18]));
soc([16, 19]) = soc([15,18]) + dsoc([9,11]);
dsoc([10,12]) = (1 - aBarNight)*(maxCharge - soc([16, 19]));
soc([17, 20]) = soc([16, 19]) + dsoc([10,12]);
end
