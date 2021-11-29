function [b, A] = getCGroup(Graph, Constant)
TYPE = Constant.edge.idx.TYPE;
YEDGE = Constant.edge.idx.YEDGE;
EDGE_GROUP = Constant.edge.idx.GROUP;
END_NODE = Constant.edge.idx.END_NODE;
NODE_GROUP = Constant.node.idx.GROUP;
types = Constant.edge.type;
nSoc = Graph.param.nSoc;
nEdge = Graph.param.nEdge;
edges = Graph.edges;
nodes = Graph.nodes;

aVals = zeros([nSoc,3]);
iVal = 1;
for iEdge = 1:nEdge
    if edges(iEdge,TYPE) == types.MOUNT
        iENode = edges(iEdge, END_NODE);
        nodeGroup = nodes(iENode,NODE_GROUP);
        iGroup = edges(iEdge, EDGE_GROUP);
        assert(iGroup == nodeGroup); 
        iYEdge = edges(iEdge, YEDGE);
        aVals(iVal,:) = [iGroup, iYEdge, 1];
        iVal = iVal + 1;
    end
    
    % add explicit zero for consistent dimensions
    if iEdge == nEdge
       iYEdge = edges(iEdge, YEDGE);
       aVals(iVal,:) = [1, iYEdge, 0];
    end
end
assert(iVal - 1 == nSoc);
A = aVals;
b = ones([max(A(:,1)),1]);
end
