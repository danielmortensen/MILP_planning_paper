function edges = formEdges(rInfo, type, Constant)
% unpack function variables
YEDGE = Constant.edge.idx.YEDGE;
START_NODE = Constant.edge.idx.START_NODE;
END_NODE = Constant.edge.idx.END_NODE;
TIME = Constant.edge.idx.TIME;
TYPE = Constant.edge.idx.TYPE;
WEIGHT = Constant.edge.idx.WEIGHT;
BUS = Constant.edge.idx.BUS;
GROUP = Constant.edge.idx.GROUP;
YDSOC = Constant.edge.idx.YDSOC;
RATE = Constant.edge.idx.RATE;
types = Constant.edge.type;


nDSoc = rInfo.nCharge;
nSoc = rInfo.nSoc;
nTime = rInfo.nTime;
nBus = rInfo.nBus;
schedule = rInfo.schedule;
nBusDSoc = rInfo.nBusDSoc;


if rInfo.scheduleType == Constant.schedule.type.DAY
    nRate = Constant.charge.nDayRate;
else
    nRate = Constant.charge.nNightRate;
end

nEdge = (rInfo.nTime - 1) + (2 + nRate)*(rInfo.nSoc - rInfo.nGroup) + 2*rInfo.nGroup;
edges = nan([nEdge,13]);

%initialize table values for non-charging edges
iEdge = 1;
iNode = 1;
for iTime = 1:nTime - 1
    edges(iEdge, YEDGE) = nDSoc + nSoc + iEdge;    
    edges(iEdge, START_NODE) = iNode;
    edges(iEdge, END_NODE) = iNode + 1;
    edges(iEdge, TIME) = iTime; %time of start node
    edges(iEdge, TYPE) = types.REST;   
    edges(iEdge, WEIGHT) = 0;    
    iEdge = iEdge + 1;
    iNode = iNode + 1;
end
iNode = iNode + 1;

%initialize table values for charging edges
iGroup = 0;
for iBus = 1:nBus    
    iSoc = 1;
    iDSoc = 1;
    for iTime = 1:nTime - 1
        lCanCharge = schedule(iBus, iTime);
        rCanCharge = schedule(iBus, iTime + 1);
        
         % update group
        if startsNewGroup(lCanCharge, rCanCharge)
            iGroup = iGroup + 1;    
        end       
        
        % charge edge
        if hasChargeEdge(lCanCharge, rCanCharge)
            for iRate = 1:nRate
                edges(iEdge, YEDGE) = nDSoc + nSoc + iEdge;
                edges(iEdge, YDSOC) = nSoc + nBusDSoc(iBus) + iDSoc;
                edges(iEdge, START_NODE) = iNode;
                edges(iEdge, END_NODE) = iNode + 1;
                edges(iEdge, TIME) = iTime;
                if type == Constant.schedule.type.DAY
                    edges(iEdge, TYPE) = types.DAY_CHARGE;
                else
                    edges(iEdge, TYPE) = types.NGT_CHARGE;
                end
                edges(iEdge, BUS) = iBus;
                edges(iEdge, WEIGHT) = 10;
                edges(iEdge, RATE) = iRate;
                iEdge = iEdge + 1;
                iDSoc = iDSoc + 1;
            end
        end
        
        % mount edge
        if hasMountEdge(lCanCharge, rCanCharge)
           edges(iEdge, YEDGE) = nDSoc + nSoc + iEdge;           
           edges(iEdge, START_NODE) = iTime;
           if startsNewGroup(lCanCharge, rCanCharge)
               edges(iEdge, END_NODE) = iNode;
           else
               edges(iEdge, END_NODE) = iNode + 1;
           end                     
           edges(iEdge, TIME) = iTime;
           edges(iEdge, TYPE) = types.MOUNT;
           edges(iEdge, BUS) = iBus;
           edges(iEdge, GROUP) = iGroup;  
           edges(iEdge, WEIGHT) = 1;
           iEdge = iEdge + 1;
        end
        
        % dismount edge
        if hasDismountEdge(lCanCharge, rCanCharge)
            edges(iEdge, YEDGE) = nDSoc + nSoc + iEdge;            
            edges(iEdge, START_NODE) = iNode;
            edges(iEdge, END_NODE) = iTime + 1;
            edges(iEdge, TIME) = iTime;
            edges(iEdge, TYPE) = types.DISMOUNT;
            edges(iEdge, BUS) = iBus;
            edges(iEdge, WEIGHT) = 0;
            iEdge = iEdge + 1;           
            iNode = iNode + 1;           
            iSoc = iSoc + 1;           
        end
    end
end
end
function out = startsNewGroup(lNode, rNode)
    out = ~lNode && rNode;
end
function out = hasDismountEdge(lNode, ~)
    out = lNode;
end
function out = hasMountEdge(~, rNode)
    out = rNode;
end
function out = hasChargeEdge(lNode, rNode)
    out = lNode && rNode;
end