function nodes = formNodes(rInfo, type, Constant)
X = Constant.node.idx.X;
Y = Constant.node.idx.Y;
TIME = Constant.node.idx.TIME;
TYPE = Constant.node.idx.TYPE;
BUS = Constant.node.idx.BUS;
YSOC = Constant.node.idx.YSOC;
GROUP = Constant.node.idx.GROUP;
types = Constant.node.type;

% unpack function variables
nTime = rInfo.nTime;
nBus = rInfo.nBus;
schedule = rInfo.schedule;
nBusSoc = rInfo.nBusSoc;
nNode = rInfo.nTime + rInfo.nSoc;
nodes = nan([nNode,8]);

%initialize table values for non-charging edges
iEdge = 1;
iNode = 1;
for iTime = 1:nTime - 1    
    nodes(iNode, X) = iTime;
    nodes(iNode, Y) = 0;   
    nodes(iNode,TIME) = iTime;
    nodes(iNode,TYPE) = types.REST;
    iEdge = iEdge + 1;
    iNode = iNode + 1;
end
nodes(iNode, X) = nTime;
nodes(iNode, Y) = 0;
nodes(iNode, TIME) = nTime;
nodes(iNode, TYPE) = types.REST;
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
           iEdge = iEdge + 1;
           iDSoc = iDSoc + 1;
        end
        
        % mount edge
        if hasMountEdge(lCanCharge, rCanCharge)          
           iEdge = iEdge + 1;
        end
        
        % dismount edge
        if hasDismountEdge(lCanCharge, rCanCharge)            
            iEdge = iEdge + 1;            
            nodes(iNode,X) = iTime;
            nodes(iNode,Y) = iBus;
            nodes(iNode,BUS) = iBus;
            nodes(iNode,YSOC) = nBusSoc(iBus) + iSoc;
            nodes(iNode,GROUP) = iGroup;
            nodes(iNode,TIME) = iTime;
            iNode = iNode + 1;            
            iSoc = iSoc + 1;           
        end
    end
end

% implement node types
tBus = 0;
for iNode = 1:nNode
    node = nodes(iNode,:);
    if node(BUS) > 0
        pNode = nodes(iNode - 1,:);
       if tBus ~= node(BUS)
       % if the node is the first for this bus, it is a start node
           tBus = node(BUS);
           nodes(iNode,TYPE) = types.START;
       elseif node(TIME) - pNode(TIME) == 1
           if type == Constant.schedule.type.DAY
               nodes(iNode,TYPE) = types.DAY_CHARGE;
           else
               nodes(iNode, TYPE) = types.NGT_CHARGE;
           end
       else
           nodes(iNode,TYPE) = types.DISMOUNT;           
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