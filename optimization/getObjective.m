function obj = getObjective(Graph, Const)
objectiveType = Graph.param.base.minimization;
obj = zeros([Graph.param.nSolution,1]);                                %#ok
if strcmp(objectiveType, 'flatConsumption')
    obj = zeros([Graph.param.nSolution,1]);
    obj = addFlatConsumption(obj,Graph, Const);
elseif strcmp(objectiveType, 'weightedConsumption')
    obj = zeros([Graph.param.nSolution,1]);
    obj = addWeightedConsumption(obj, Graph, Const);
elseif strcmp(objectiveType, 'baseline')
    B = toSparse(Graph.Constraint.group.A, Graph.param.nSolution);
    obj = ones([1, size(B,1)])*B;
elseif contains(objectiveType, 'Schedule8')
   obj = zeros([Graph.param.nSolution,1]);
   obj(end) = 15.73; % rocky mountain power charge rate for on peak per kw
   obj(end - 1) = 4.81; % rocky mountain facilities charge per kw
   obj = addWeightedConsumption(obj, Graph, Const);
   
% small penalty to avoid spurious mount/dismounts
obj = addDismountPenaltyToObjective(obj,Graph,Const);

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
[dIdx, dIdxOnPeak] = getDSocIdx(Graph, Const);
obj(dIdx) = 0.029624;
obj(dIdxOnPeak) = 0.058282;
% nTime = Graph.param.nTime;
% for iTime = 1:nTime - 1
%     eSelectionIdx = Graph.edges(:,Const.edge.idx.TIME) == iTime;
%     eSelection = Graph.edges(eSelectionIdx,:);
%     eSelectionIdx = ~isnan(eSelection(:,Const.edge.idx.YDSOC));
%     eSelection = eSelection(eSelectionIdx,:);
%     dSocIdx = eSelection(:,Const.edge.idx.YDSOC);
%     if Graph.param.isOnPeak(iTime + 1)
%         obj(dSocIdx) = 0.058282;
%     else
%         obj(dSocIdx) = 0.029624;
%     end
% end
end