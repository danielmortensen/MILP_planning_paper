function [b, A, externalLoad, time, constraintType] = getCDemand(Graph, Constant)
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
M = Constant.disoptimality;
yDemandIdx = nSoc + nEdge + nDSoc + 1;
ySelectorIdx = yDemandIdx + 4;
nPerInterval = round(15/dTime);
nHoursPerTimestep = dTime/60;
vals = nan([nEdge*4,3]);
iConstr = 1;
if islogical(fLoadProfile) && ~fLoadProfile
    externalLoad = zeros([nTime,1]);
else
    externalLoad = getExternalLoad(fLoadProfile, dTime, tStart, nTime, syncTime);
end
% convert kw to kwh consumed in each timestep
externalLoad = externalLoad*dTime/60;
b = zeros([nTime*2 + 1,1]);
time = (0:nTime - 1)*dTime + tStart;
for iTime = 2:nTime
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
        vals(iConstr,:) = [iTime, iDSoc, avgValue];
        vals(iConstr + 1,:) = [iTime + nTime, iDSoc, -avgValue];        
        iConstr = iConstr + 2;
    end
    vals(iConstr,:) = [iTime, yDemandIdx, -1];  
    vals(iConstr + 1,:) = [iTime + nTime, yDemandIdx, 1];
    vals(iConstr + 2,:) = [iTime + nTime, ySelectorIdx + iTime, M]; 
    vals(iConstr + 3,:) = [2*nTime + 1,ySelectorIdx + iTime,1];
    b(iTime) = -sum(externalLoad(iStart:iTime))*avgValue;
    b(iTime + nTime) = -b(iTime) + M;
    iConstr = iConstr + 4;
end
b(2*nTime + 1) = 1;
vals = vals(~any(isnan(vals),2),:);
A = vals;
constraintType = [repmat('<',[2*nTime, 1]);...
                  repmat('=',[1      , 1]);];
end
