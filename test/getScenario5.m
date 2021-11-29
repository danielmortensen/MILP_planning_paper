% test scenario with
% - 2 charger
% - 2 bus
% - multirate rate, nRate = 3;
% - day/night charging
% - no charge
function [G, Const, solution] = getScenario5()
addpath('../');
Scen = getScenario('startBusSocAt',80,'nNightChargeRate',1,...
                   'nDayChargeRate',3);
initialSoc = 80;
Const = getConstant(Scen);
[p0, p1, p2] = getTestProfiles(initialSoc);
G0 = formGraph(p0, Const);
G1 = formGraph(p1, Const);
G2 = formGraph(p2, Const);
GList = [G0, G1, G2];
G = combineModels(GList, Const);
solution = getNoChargeSolution(initialSoc, Const);
end
function solution = getNoChargeSolution(initialSoc, Const)
[soc, dsoc] = computeTestSoc(initialSoc, Const);
nNightRate = numel(Const.charge.R_NIGHT);
nDayRate = numel(Const.charge.R_DAY);
nightEdge = zeros([1,6 + 2*nNightRate]);
dayEdge = zeros([1,8 + 2*nDayRate]);
nightEdges = [2*ones([1,4]), nightEdge, nightEdge];
dayEdges = [2*ones([1,6]), dayEdge, dayEdge];
dayDemand = sum(dsoc([1,2,3,4]))/2;
nightDemand = sum(dsoc([5,7]))/2;
demand = max(dayDemand, nightDemand);
demandOnPeak = 0;
idx1 = 4*nNightRate;
idx2 = idx1 + 4*nDayRate;
idx3 = idx2 + 4*nNightRate;
solution = [soc(1:6),  dsoc(1:idx1), nightEdges,...
            soc(7:14), dsoc(idx1 + 1:idx2), dayEdges,...
            soc(15:20),dsoc(idx2 + 1:idx3),nightEdges,...
            demand, demandOnPeak]';
end

function [soc, dsoc] = computeTestSoc(initialSoc, Const)
discharge = 20;
nDayRate = numel(Const.charge.R_DAY);
nNightRate = numel(Const.charge.R_NIGHT);
soc = zeros([1,20]);
dsoc = zeros([1,4*nNightRate + 4*nDayRate + 4*nNightRate]);
soc([1,4]) = initialSoc;
soc([2,5]) = soc([1,4]);
soc([3,6]) = soc([2,5]);
soc([7, 11]) = soc([3, 6]);
soc([8, 12]) = soc([7, 11]);
soc([9, 13]) = soc([8, 12]) - discharge;
soc([10, 14]) = soc([9, 13]);
soc([15, 18]) = soc([10, 14]);
soc([16, 19]) = soc([15,18]);
soc([17, 20]) = soc([16, 19]);
end
