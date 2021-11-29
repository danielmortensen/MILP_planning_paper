function [cBEntries, cAEntries] = getCIncidence(Graph, Constant)
% edge constant values
eStartNodeIdx = Constant.edge.idx.START_NODE;
eEndNodeIdx = Constant.edge.idx.END_NODE;
eSolIdx = Constant.edge.idx.YEDGE;

% node constant values
ndTimeIdx = Constant.node.idx.TIME;

% graph metadata
nCharger = Graph.param.nCharger;
nEdge = Graph.param.nEdge;
nNode = Graph.param.nNode;

% necessary graph components
nodes = Graph.nodes;
edges = Graph.edges;

% build constraint matrix
cAEntries = nan([nEdge*2, 3]);
cIdx = 1;
for iEdge = 1:nEdge
    sNode = edges(iEdge,eStartNodeIdx);
    fNode = edges(iEdge,eEndNodeIdx);
    solEdgeIdx = edges(iEdge,eSolIdx);    
    cAEntries(cIdx,:) = [sNode, solEdgeIdx, -1];
    cAEntries(cIdx + 1,:) = [fNode, solEdgeIdx, 1];
    cIdx = cIdx + 2;
end

% get indices for night/day transitions
transitionIdxs = getGTransitionIdx(Graph.chargeType);

% build right-hand side (i.e. source and sink constraints)
cBEntries = zeros([nNode,1]);
nTransition = numel(transitionIdxs);
ndTimes = Graph.nodes(:,ndTimeIdx);

% loop over source/sink constraints for each graph transition
cBEntries(1) = -nCharger(1);
for iTransition = 1:nTransition
    % intermediate sink constraint
    transitionIdx = transitionIdxs(iTransition);
    iNodeMatch = find(ndTimes == transitionIdx);
    iNode = iNodeMatch(1);
    cBEntries(iNode) = nCharger(iTransition);
    
    % intermediate source constraint
    iNodeMatch = find(ndTimes == transitionIdx + 1);
    iNode = iNodeMatch(1);
    cBEntries(iNode) = -nCharger(iTransition + 1);
end

% final sink constraint
[~, iMaxNode] = max(nodes(:,ndTimeIdx));
cBEntries(iMaxNode) = nCharger(end);
end

function transitionIdx = getGTransitionIdx(gType)
transitionIdx = [];
nTime = numel(gType);
for iTime = 2:nTime
    if gType(iTime - 1) - gType(iTime) ~= 0
        transitionIdx = [transitionIdx; iTime - 1];                                     %#ok
    end
end
end