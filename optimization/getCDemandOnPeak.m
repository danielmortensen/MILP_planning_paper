function [b, A, constraintType] = getCDemandOnPeak(Graph, Constant)
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
yDemandIdx = Graph.param.yOnPeakDemandIdx;
nOnPeak = sum(Graph.param.isOnPeak);
ySelectorIdx = nSoc + nDSoc + nEdge + 4 + nTime + 1;
M = Constant.disoptimality;
nPerInterval = round(15/dTime);
nHoursPerTimestep = dTime/60;
vals = nan([nEdge*4,3]);
iConstr = 1;
if islogical(fLoadProfile) && ~fLoadProfile
    externalLoad = zeros([nTime,1]);
else
    externalLoad = getExternalLoad(fLoadProfile, dTime, tStart, nTime, syncTime);
end
externalLoad = externalLoad*(dTime/60);
b = nan([nTime*2 + 1,1]);

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
        vals(iConstr + 1,:) = [iConstr2 + nOnPeak, iDSoc, -avgValue];        
        iConstr = iConstr + 2;
    end
    vals(iConstr,:) = [iConstr2, yDemandIdx, -1];
    vals(iConstr + 1,:) = [iConstr2 + nOnPeak, yDemandIdx, 1];
    vals(iConstr + 2,:) = [iConstr2 + nOnPeak, ySelectorIdx + iConstr2, M]; 
    vals(iConstr + 3,:) = [2*nOnPeak + 1,ySelectorIdx + iConstr2,1];
    b(iConstr2) = -sum(externalLoad(iStart:iTime))*avgValue;
    b(iConstr2 + nOnPeak) = -b(iConstr2) + M;
    iConstr = iConstr + 4;
    iConstr2 = iConstr2 + 1;
end
b(2*nOnPeak + 1) = 1;
b = b(~isnan(b));
vals = vals(~any(isnan(vals),2),:);
A = vals;
constraintType = [repmat('<',[2*nOnPeak,1]);...
                  repmat('=',[1,            1]);];
end