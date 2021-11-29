function [b, A] = getCTotalCost(G, Const)
nSolution = G.param.nSolution;
cost = getObjective(G, Const, 'Schedule8');
cost(G.param.yTotalCostIdx) = -1;
A = [ones([nSolution,1]) (1:nSolution)', cost];
b = 0;
end