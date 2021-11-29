function GList = updateGraph(GList, Const)

nGraph = length(GList);

for iGraph = 2:nGraph
G1 = GList(iGraph - 1);
G2 = GList(iGraph);

% extract relevent variables
if isfield(G1.param,'nAllGroup')
    nGroup = G1.param.nAllGroup;
    nTime = G1.param.nAllTime;
    nDSoc = G1.param.nAllDSoc;
    nSoc = G1.param.nAllSoc;
    nEdge = G1.param.nAllEdge;
    nNode = G1.param.nAllNode;
else
p2.tEnd = 1440;
p2.dTime = dTime;
p2.fleetProfile = fleetProfile1;
p2.base = base;
p2.speed = 0;
p2.nCharger = nBus;
    nGroup = G1.param.fleetProfile.nGroup;
    nTime = G1.param.fleetProfile.nTime;
    nSoc = G1.param.fleetProfile.nSoc;
    nDSoc = G1.param.fleetProfile.nCharge;
    nEdge = G1.param.nEdge;   
    nNode = G1.param.nNode;    

end
nVar = nSoc + nDSoc + nEdge;

% update nodes
GList(iGraph).nodes(:,Const.node.idx.GROUP) = G2.nodes(:,Const.node.idx.GROUP) + nGroup;
GList(iGraph).nodes(:,Const.node.idx.X) = G2.nodes(:,Const.node.idx.X) + nTime;
GList(iGraph).nodes(:,Const.node.idx.TIME) = G2.nodes(:,Const.node.idx.TIME) + nTime;
GList(iGraph).nodes(:,Const.node.idx.YSOC) = G2.nodes(:,Const.node.idx.YSOC) + nVar;
iNodeMatch = GList(iGraph).nodes(:,Const.node.idx.TYPE) == Const.node.type.START;
GList(iGraph).nodes(iNodeMatch,Const.node.idx.TYPE) = Const.node.type.FUSE_POST;

% update metadata to be used for the next graph
GList(iGraph).param.nAllGroup = G2.param.fleetProfile.nGroup + nGroup;
GList(iGraph).param.nAllTime = G2.param.fleetProfile.nTime + nTime;
GList(iGraph).param.nAllDSoc = G2.param.fleetProfile.nCharge + nDSoc;
GList(iGraph).param.nAllSoc = G2.param.fleetProfile.nSoc + nSoc;
GList(iGraph).param.nAllEdge = G2.param.nEdge + nEdge;
GList(iGraph).param.nAllNode = G2.param.nNode + nNode;

% update edges
GList(iGraph).edges(:,Const.edge.idx.END_NODE) = G2.edges(:,Const.edge.idx.END_NODE) + nNode;
GList(iGraph).edges(:,Const.edge.idx.START_NODE) = G2.edges(:,Const.edge.idx.START_NODE) + nNode;
GList(iGraph).edges(:,Const.edge.idx.YEDGE) = G2.edges(:,Const.edge.idx.YEDGE) + nVar;
GList(iGraph).edges(:,Const.edge.idx.YDSOC) = G2.edges(:,Const.edge.idx.YDSOC) + nVar;
GList(iGraph).edges(:,Const.edge.idx.GROUP) = G2.edges(:,Const.edge.idx.GROUP) + nGroup;
GList(iGraph).edges(:,Const.edge.idx.TIME) = G2.edges(:,Const.edge.idx.TIME) + nTime;
end

for iGraph = 1:nGraph - 1
    G = GList(iGraph);
    GEnd = GList(nGraph);
    % update metadata to be used for the next graph
    G.param.nAllGroup = GEnd.param.nAllGroup;
    G.param.nAllTime = GEnd.param.nAllTime;
    G.param.nAllDSoc = GEnd.param.nAllDSoc;
    G.param.nAllSoc = GEnd.param.nAllSoc;
    G.param.nAllEdge = GEnd.param.nAllEdge;
    G.param.nAllNode = GEnd.param.nAllNode;
    GList(iGraph) = G;
end
end
