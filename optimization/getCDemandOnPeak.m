function [b, A] = getCDemandOnPeak(Graph, Constant)
TYPE = Constant.edge.idx.TYPE;
types = Constant.edge.type;
YDSOC = Constant.edge.idx.YDSOC;
TIME = Constant.edge.idx.TIME;
nSoc = Graph.param.nSoc;
nEdge = Graph.param.nEdge;
nDSoc = Graph.param.nDSoc;
dTime = Graph.param.base.dTime;
nTime = Graph.param.nTime;
fLoadProfile = Graph.param.base.fLoadProfile;
tStart = Graph.param.tStart;
syncTime = Graph.param.syncTime;
edges = Graph.edges;

nPrevConstr = nSoc + nEdge + nDSoc + 1;
nPerInterval = round(15/dTime);
nHoursPerTimestep = dTime/60;
vals = nan([nEdge,3]);
iConstr = 1;
if islogical(fLoadProfile) && ~fLoadProfile
    externalLoad = zeros([nTime,1]);
else
    externalLoad = getExternalLoad(fLoadProfile, dTime, tStart, nTime, syncTime);
end
externalLoad = externalLoad*(dTime/60);
b = nan([nTime,1]);
iConstr2 = 1;
for iTime = 2:nTime
    if ~Graph.param.isOnPeak(iTime)
        continue;
    end
    iStart = iTime - nPerInterval + 1;
    if iStart < 1
        iStart = 1;
    end
    nTimeInterval = iTime - iStart + 1;
    avgValue = 1/(nTimeInterval*nHoursPerTimestep);
    iEdge = (edges(:,TYPE) == types.DAY_CHARGE | edges(:,TYPE) == types.NGT_CHARGE) & ...
        (edges(:,TIME) >= iStart & edges(:,TIME) <= iTime);
    iDSocs = edges(iEdge,YDSOC);
    cDSoc = size(iDSocs,1);
    for iIDSoc = 1:cDSoc
        iDSoc = iDSocs(iIDSoc);
        vals(iConstr,:) = [iConstr2, iDSoc, avgValue];
        iConstr = iConstr + 1;
    end
    vals(iConstr,:) = [iConstr2, nPrevConstr + 1, -1];  
    b(iConstr2) = -sum(externalLoad(iStart:iTime))*avgValue;
    iConstr = iConstr + 1;
    iConstr2 = iConstr2 + 1;
end
b = b(~isnan(b));
vals = vals(~any(isnan(vals),2),:);
A = vals;
end