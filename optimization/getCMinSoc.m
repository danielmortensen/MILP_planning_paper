function [b, A] = getCMinSoc(Graph, Constant)
YSOC = Constant.node.idx.YSOC;
TYPE = Constant.node.idx.TYPE;
types = Constant.node.type;
nSoc = Graph.param.nSoc;
nNode = Graph.param.nNode;
nodes = Graph.nodes;
minSoc = Graph.param.base.minSoc;
nRow = nSoc;
A = nan([nNode,3]);
b = -ones([nRow,1])*minSoc;
iConstr = 1;
for iNode = 1:nNode
    type = nodes(iNode,TYPE);
    if type ~= types.REST
        iYSoc = nodes(iNode,YSOC);
        A(iNode,:) = [iConstr, iYSoc, -1];
        iConstr = iConstr + 1;
    end
end
A = A(~any(isnan(A),2),:);
end
