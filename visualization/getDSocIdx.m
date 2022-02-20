function [idx, idxOnPeak] = getDSocIdx(Graph, Const)
nTime = Graph.param.nTime;
nSolution = Graph.param.nSolution;
idx = zeros([nSolution, 1]);
idxOnPeak = zeros([nSolution, 1]);
for iTime = 1:nTime - 1
    eSelectionIdx = Graph.edges(:,Const.edge.idx.TIME) == iTime;
    eSelection = Graph.edges(eSelectionIdx,:);
    eSelectionIdx = ~isnan(eSelection(:,Const.edge.idx.YDSOC));
    eSelection = eSelection(eSelectionIdx,:);
    dSocIdx = eSelection(:,Const.edge.idx.YDSOC);
    if Graph.param.isOnPeak(iTime + 1)
        idxOnPeak(dSocIdx) = idxOnPeak(dSocIdx) + 1;
    end
    idx(dSocIdx) = idx(dSocIdx) + 1;
end
assert(all(idx < 2));
assert(all(idxOnPeak < 2));
idx = logical(idx);
idxOnPeak = logical(idxOnPeak);
end