function obj = getObjective(Graph, Const, objectiveType)
if nargin == 2
    objectiveType = Graph.param.base.minimization;
end
if strcmp(objectiveType, 'flatConsumption')
    obj = zeros([Graph.param.nSolution,1]);
    obj = addFlatConsumption(obj,Graph, Const);
    obj = addDismountPenaltyToObjective(obj,Graph,Const);
elseif contains(objectiveType, 'Schedule8')
   obj = zeros([Graph.param.nSolution,1]);
   obj(Graph.param.yOnPeakDemandIdx) = 15.73; % rocky mountain power charge rate for on peak per kw
   obj(Graph.param.yFacilitiesIdx) = 4.81; % rocky mountain facilities charge per kw
   obj = addWeightedConsumption(obj, Graph, Const);
   obj = addDismountPenaltyToObjective(obj,Graph,Const);
elseif contains(objectiveType, 'disoptimal')
    obj = zeros([Graph.param.nSolution,1]);
    obj(Graph.param.yWorstCaseIdx) = 1;
else
    error('invalid minimization objective');
end
end
function obj = addDismountPenaltyToObjective(obj, Graph,Const)
mountIdx = Graph.edges(:,Const.edge.idx.TYPE) == Const.edge.type.DISMOUNT;
yMountIdx = Graph.edges(mountIdx,Const.edge.idx.YEDGE);
obj(yMountIdx) = 0.1;
end

function obj = addFlatConsumption(obj, Graph, Const)
nTime = Graph.param.nTime;
for iTime = 1:nTime - 1
    eSelectionIdx = Graph.edges(:,Const.edge.idx.TIME) == iTime;
    eSelection = Graph.edges(eSelectionIdx,:);
    eSelectionIdx = ~isnan(eSelection(:,Const.edge.idx.YDSOC));
    eSelection = eSelection(eSelectionIdx,:);
    dSocIdx = eSelection(:,Const.edge.idx.YDSOC);
    obj(dSocIdx) = 10;    
end
end
function obj = addWeightedConsumption(obj, Graph, Const)
nTime = Graph.param.nTime;
for iTime = 1:nTime - 1
    eSelectionIdx = Graph.edges(:,Const.edge.idx.TIME) == iTime;
    eSelection = Graph.edges(eSelectionIdx,:);
    eSelectionIdx = ~isnan(eSelection(:,Const.edge.idx.YDSOC));
    eSelection = eSelection(eSelectionIdx,:);
    dSocIdx = eSelection(:,Const.edge.idx.YDSOC);
    if Graph.param.isOnPeak(iTime + 1)
        obj(dSocIdx) = 0.058282;
    else
        obj(dSocIdx) = 0.029624;
    end
end
end