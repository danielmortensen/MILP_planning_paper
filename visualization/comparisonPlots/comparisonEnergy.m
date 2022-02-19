function comparisonEnergy(maxResult, minResult)
fig = figure; hold on; 
uncontrolledLoad = maxResult.G.extern.load;
xVal = max(uncontrolledLoad);
nVal = min(uncontrolledLoad);

plot(uncontrolledLoad,'color',[0.9290, 0.6940, 0.1250, 0.5]);
plotSingleComparison(maxResult.G, maxResult.result.x, maxResult.Const);
plotSingleComparison(minResult.G, minResult.result.x, minResult.Const, xVal, nVal);
legend('Uncontrolled load','Bus Load - Worst Case', 'Bus Load - Optimized Case', 'On-Peak Time Interval');
ylabel('Kwh');
title('Energy Usage');
end



function plotSingleComparison(G, result, Const, maxVal, minVal)
nTime = G.param.nTime;
busEnergy = zeros([nTime,1]);
for iTime = 1:nTime
    edgeSelectIdx = G.edges(:,Const.edge.idx.TIME) == iTime;
    edgeDsocIdx = G.edges(edgeSelectIdx,Const.edge.idx.YDSOC);
    edgeDsocIdx = edgeDsocIdx(~isnan(edgeDsocIdx));
    if ~isempty(edgeDsocIdx)
        busEnergy(iTime) = sum(result(edgeDsocIdx));
    else
        busEnergy(iTime) = 0;
    end
end
plot(busEnergy);
if nargin == 5
    addTimeAxis(gca, nTime, 60*24);
    dTime = G.param.base.dTime;
    addOnPeakShading(gca, maxVal, minVal, dTime);
end
end