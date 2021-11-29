% test scenario with
% - 2 charger
% - 2 bus
% - single rate
% - day/night charging
% - no charge
function [G, Const, solution] = getScenario3()
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
solution = getNoChargeSolution(initialSoc);
end
function solution = getNoChargeSolution(initialSoc)
[soc, dsoc] = computeTestSoc(initialSoc);
nightEdge = zeros([1,8]);
dayEdge = zeros([1,10]);
nightEdges = [2*ones([1,4]), nightEdge, nightEdge];
dayEdges = [2*ones([1,6]), dayEdge, dayEdge];
dayDemand = sum(dsoc([1,2,3,4]))/2;
nightDemand = sum(dsoc([5,7]))/2;
demand = max(dayDemand, nightDemand);
demandOnPeak = 0;
solution = [soc(1:6),  dsoc(1:4), nightEdges,...
            soc(7:14), dsoc(5:8), dayEdges,...
            soc(15:20),dsoc(9:12),nightEdges,...
            demand demandOnPeak]';
end

function [soc, dsoc] = computeTestSoc(initialSoc)
discharge = 20;
soc = zeros([1,20]);
dsoc = zeros([1,12]);
soc([1,4]) = initialSoc;
soc([2,5]) = soc([1,4]) + dsoc([1,3]);
soc([3,6]) = soc([2,5]) + dsoc([2,4]);
soc([7, 11]) = soc([3, 6]);
soc([8, 12]) = soc([7, 11]) + dsoc([5, 7]);
soc([9, 13]) = soc([8, 12]) - discharge;
soc([10, 14]) = soc([9, 13]) + dsoc([6, 8]);
soc([15, 18]) = soc([10, 14]);
soc([16, 19]) = soc([15,18]) + dsoc([9,11]);
soc([17, 20]) = soc([16, 19]) + dsoc([10,12]);
end
