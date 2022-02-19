function [b, A, b2, A2] = getCSoc(Graph, Constant)
types = Constant.node.type;
TYPE = Constant.node.idx.TYPE;
YSOC = Constant.node.idx.YSOC;
BUS = Constant.node.idx.BUS;
TIME = Constant.node.idx.TIME;
nSoc = Graph.param.nSoc;

discharge = Graph.param.discharge;
soc = Graph.param.soc;
nNode = Graph.param.nNode;
nodes = Graph.nodes;
[lastTimes, nBus] = getLastBusTime(nodes, Constant);
iConstr = 1;
nRow = nSoc;
maxNRate = max([Constant.charge.nDayRate, Constant.charge.nNightRate]);
maxNCon = 2 + maxNRate;
A = nan([nNode*maxNCon,3]);
b = zeros([nRow,1]);
A2 = nan([(nBus)*maxNCon,3]);
b2 = zeros([nBus,1]);
iConstr2 = 1;
for iNode = 1:nNode
    iBus = nodes(iNode,BUS);
    if isLastBusNode(iBus, iNode, nodes, Constant, lastTimes)
        initSoc = soc(iBus);
        iYSoc = nodes(iNode, YSOC);
        A2(iBus*maxNCon + 1,:) = [iConstr2, iYSoc, -1];
        b2(iConstr2) = -initSoc;
        iConstr2 = iConstr2 + 1;
    end
    if nodes(iNode,TYPE) == types.START 
        initSoc = soc(iBus);
        iYSoc = nodes(iNode, YSOC);
        A((iNode - 1)*maxNCon + 1,:) = [iConstr, iYSoc, 1];
        b(iConstr) = initSoc;
        iConstr = iConstr + 1;
    elseif nodes(iNode,TYPE) == types.DAY_CHARGE || nodes(iNode,TYPE) == types.NGT_CHARGE
        iYSocPrev = nodes(iNode- 1,YSOC);
        iYSoc = nodes(iNode , YSOC);
        iEdge = Graph.edges(:,Constant.edge.idx.END_NODE) == iNode;
        edgeTypes = Graph.edges(:,Constant.edge.idx.TYPE);
        isDayCharge = edgeTypes == Constant.edge.type.DAY_CHARGE;
        isNgtCharge = edgeTypes == Constant.edge.type.NGT_CHARGE;
        iEdge = iEdge & (isDayCharge | isNgtCharge);
        iYDSoc = Graph.edges(iEdge, Constant.edge.idx.YDSOC);
        
        A((iNode - 1)*maxNCon + 1,:) = [iConstr,iYSocPrev, 1];
        A((iNode - 1)*maxNCon + 2,:) = [iConstr, iYSoc, -1];
        for yDSocIdx = 1:numel(iYDSoc)           
            currYDSoc = iYDSoc(yDSocIdx);
            A((iNode - 1)*maxNCon + 2 +  yDSocIdx,:) = [iConstr, currYDSoc, 1];
        end
        iConstr = iConstr + 1;

    elseif nodes(iNode,TYPE) == types.DISMOUNT
        iYSocPrev = nodes(iNode - 1,YSOC);
        iYSoc = nodes(iNode, YSOC);
        iBus = nodes(iNode, BUS);
        routeDelta = discharge(iBus);
        A((iNode - 1)*maxNCon + 1,:) = [iConstr, iYSocPrev, 1];
        A((iNode - 1)*maxNCon + 2,:) = [iConstr, iYSoc, -1];
        b(iConstr) = routeDelta;
        iConstr = iConstr + 1;
    elseif nodes(iNode, TYPE) == types.FUSE_POST
        y1 = nan;
        cIdx = nodes(iNode, TIME) - 1;
        iBus = nodes(iNode, BUS);
        while isnan(y1)
            iNodeMatch = Graph.nodes(:,TIME) == cIdx;
            iNodeMatch = iNodeMatch & Graph.nodes(:,BUS) == iBus;
            if any(iNodeMatch)
                nodeMatch = Graph.nodes(iNodeMatch,:);
                y1 = nodeMatch(1,YSOC);
            else
                cIdx = cIdx - 1;
            end               
        end
        y2 = nodes(iNode, YSOC);
        A((iNode - 1)*maxNCon + 1,:) = [iConstr, y1, -1];
        A((iNode - 1)*maxNCon + 2,:) = [iConstr, y2,  1];
        b(iConstr) = 0;
        iConstr = iConstr + 1;
    end
end 
A = A(~any(isnan(A),2),:);
A2 = A2(~any(isnan(A2),2),:);
assert(iConstr - 1 == nRow);
end

function [lastNodeTime, nBus] = getLastBusTime(nodes, Constant)
nBus = sum(~isnan(unique(nodes(:,Constant.node.idx.BUS))));
lastNodeTime = zeros([nBus,1]);
BUS = Constant.node.idx.BUS;
TIME = Constant.node.idx.TIME;

for iBus = 1:nBus
    busNodeIdx = (nodes(:,BUS) == iBus);
    busNode = nodes(busNodeIdx,:);
    busTime = busNode(:,TIME);
    lastNodeTime(iBus) = max(busTime); 
end
end

function out = isLastBusNode(iBus, iNode, nodes, Constant, times)
if isnan(iBus)
    out = false;
else
    out = nodes(iNode,Constant.node.idx.TIME) == times(iBus);
end
end
