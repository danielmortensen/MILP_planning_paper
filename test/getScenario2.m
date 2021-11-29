% test scenario with
% - single charger
% - 2 bus
% - single rate
% - daytime charging only
% - all charge
function [G, Const, solution] = getScenario2()
addpath('../');
Scen = getScenario('startBusSocAt',80, 'nNightChargeRate',1,...
                    'nDayChargeRate',1);
initialSoc = 80;
Const = getConstant(Scen);
[~, p1, ~] = getTestProfiles(initialSoc);
G = formGraph(p1, Const);
solution = getNoChargeSolution(initialSoc, Const, p1.base.dTime);
end
function solution = getNoChargeSolution(initialSoc, Const, tDelta)
[soc, dsoc] = computeTestSoc(initialSoc, Const, tDelta);
busEdge = [1 1 0 0 1 1 1 0 0 1];
edges = [zeros([1,6]) busEdge busEdge];
demand = sum(dsoc([2,4]))*4;
demandOnPeak = sum(dsoc([1,3]))*6;
solution = [soc, dsoc, edges, demand, demandOnPeak]';
end

function [soc, dsoc] = computeTestSoc(initialSoc, Const, tDelta)
discharge = 20;
maxCharge = 100;
rate = Const.charge.R_DAY;
aBar = exp(rate*tDelta);
soc = zeros([1,8]);
dsoc = zeros([1,4]);
soc([1,5]) = initialSoc;
dsoc([1,3]) = (1 - aBar)*(maxCharge - initialSoc);
soc([2,6]) = soc([1,5]) + dsoc([1,3]);
soc([3,7]) = soc([2,6]) - discharge;
dsoc([2,4]) = (1 - aBar)*(maxCharge - soc([3,7]));
soc([4,8]) = soc([3,7]) + dsoc([2,4]);
end

