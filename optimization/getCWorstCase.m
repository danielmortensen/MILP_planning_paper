function [b, A] = getCWorstCase(G, Const)
A = [1,G.param.yTotalCostIdx,1;...
     1,G.param.yWorstCaseIdx,-1;...
     2,G.param.yWorstCaseIdx,-1];
b = [Const.disoptimality;
     0];
end