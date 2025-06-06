function Graph = formGraph(pGraph, Const)
% initialize route
busInfo = getRoute(pGraph, Const);
type = pGraph.scheduleType;
maxSoc = Const.charge.MAX_CHARGE;

% initialize simulation variables
edges = formEdges(busInfo,type,Const);
edges(edges(:,Const.edge.idx.YDSOC) == 0,Const.edge.idx.YDSOC) = nan;
nodes = formNodes(busInfo,type,Const);
nNode = size(nodes,1);
nEdge = size(edges,1);
pGraph.nEdge = nEdge;
pGraph.nNode = nNode;
pGraph.fleetProfile = busInfo;
Graph.param = pGraph;
Graph.edges = edges;
Graph.nodes = nodes;
Graph.chargeType = ones([Graph.param.fleetProfile.nTime,1])*pGraph.scheduleType;
Graph.param.nAllGroup = Graph.param.fleetProfile.nGroup;
Graph.param.nAllTime = Graph.param.fleetProfile.nTime;
Graph.param.nAllDSoc = Graph.param.fleetProfile.nCharge;
Graph.param.nAllSoc = Graph.param.fleetProfile.nSoc;
Graph.param.nAllEdge = Graph.param.nEdge;
Graph.param.nAllNode = Graph.param.nNode;
Graph.param.nGroup = Graph.param.fleetProfile.nGroup;
Graph.param.nTime = Graph.param.fleetProfile.nTime;
Graph.param.nDSoc = Graph.param.fleetProfile.nCharge;
Graph.param.nSoc = Graph.param.fleetProfile.nSoc;
Graph.param.discharge = Graph.param.fleetProfile.discharge;
Graph.param.soc = Graph.param.fleetProfile.soc;
Graph.param.varType = [repmat('C',[busInfo.nSoc,1]);...
                       repmat('C',[busInfo.nCharge,1]);...               
                       repmat('I',[nEdge, 1])];
Graph.param.upperBound = [repmat(maxSoc,[busInfo.nSoc,1]);...
                          repmat(maxSoc,[busInfo.nCharge,1]);...
                          repmat(Graph.param.nCharger,[nEdge,1])];
Graph.param.lowerBound = [zeros([busInfo.nSoc,1]);...
                          zeros([busInfo.nCharge,1]);...
                          zeros([nEdge,1])];
Graph.param.isOnPeak = Graph.param.fleetProfile.isOnPeak;
Graph.param.tStart = Graph.param.fleetProfile.tStart;
Graph.param.nSolution = Graph.param.nAllSoc + Graph.param.nAllDSoc + nEdge + 2;
end