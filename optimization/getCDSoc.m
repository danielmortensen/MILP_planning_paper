function [b, A] = getCDSoc(Graph, Constant)
TYPE = Constant.edge.idx.TYPE;
types = Constant.edge.type;
START_NODE = Constant.edge.idx.START_NODE;
NYSOC = Constant.node.idx.YSOC;
YDSOC = Constant.edge.idx.YDSOC;
YEDGE = Constant.edge.idx.YEDGE;
TIME = Constant.edge.idx.TIME;
RATE = Constant.edge.idx.RATE;
dTime = Graph.param.base.dTime; 
nDSoc = Graph.param.nDSoc;
nEdge = Graph.param.nEdge;
edges = Graph.edges;
nodes = Graph.nodes;

maxCharge = Constant.charge.MAX_CHARGE;
A = nan([nEdge*8,3]);
b = nan([nDSoc*4,1]);
iConst = 1;

for iEdge = 1:nEdge    
    if edges(iEdge,TYPE) == types.DAY_CHARGE || edges(iEdge,TYPE) == types.NGT_CHARGE
        if edges(iEdge,TYPE) == types.DAY_CHARGE
            rateCoef = Constant.charge.R_DAY(edges(iEdge,RATE));
        else
            rateCoef = Constant.charge.R_NIGHT(edges(iEdge,RATE));
        end
        chargeA = exp(rateCoef*dTime);
        chargeB = (chargeA - 1);
        iNode = edges(iEdge, START_NODE);
        iSoc = nodes(iNode, NYSOC);
        iDSoc = edges(iEdge, YDSOC);
        iYEdge = edges(iEdge, YEDGE);
        A((iEdge - 1)*8 + 1,:) = [iConst, iYEdge, maxCharge];
        A((iEdge - 1)*8 + 2,:) = [iConst, iSoc, chargeA - 1];
        A((iEdge - 1)*8 + 3,:) = [iConst, iDSoc, -1];     
        b(iConst) = maxCharge*(chargeB + 1);
        
        A((iEdge - 1)*8 + 4,:) = [iConst + 1, iSoc, -(chargeA - 1)];
        A((iEdge - 1)*8 + 5,:) = [iConst + 1, iDSoc, 1];
        b(iConst + 1) = -chargeB*maxCharge;
        
        A((iEdge - 1)*8 + 6,:) = [iConst + 2, iDSoc, -1];
        b(iConst + 2) = 0;
        
        A((iEdge - 1)*8 + 7,:) = [iConst + 3, iYEdge, -maxCharge];
        A((iEdge - 1)*8 + 8,:) = [iConst + 3, iDSoc, 1];
        b(iConst + 3) = 0;
        
        iConst = iConst + 4;    
    end
end
A = A(~any(isnan(A),2),:);
b = b(~any(isnan(b),2),:);
end
