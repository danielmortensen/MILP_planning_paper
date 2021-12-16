function makeComparisonBusSoc(minVal, maxVal)
addpath('../');
busIdx = [2, 3];
nBus = numel(busIdx);
figure; hold on;
maxSoc = 0;
addOnPeakShading(gca,100,0,maxVal.G.param.base.dTime);
for iBus = 1:nBus
    [socMax, timeMax] = getSocVal(maxVal,busIdx(iBus));
    [socMin, timeMin] = getSocVal(minVal,busIdx(iBus));
    plot(timeMax, socMax,'color','red');
    plot(timeMin, socMin,'color','blue');
    yline(maxVal.G.param.base.minSoc,'--');
    maxSoc = max([maxSoc; socMin(:); socMax(:)]);
end
xlabel('Time'); ylabel('Bus State of Charge');
addTimeAxis(gca,max([timeMax(:);timeMin(:)]),24*60);
ylim([0,maxSoc]);
legend('On-Peak Time Interval','Unoptimized Bus SOC','Optimized Bus SOC', 'Minimum SOC');
title('Bus State of Charge (SOC) Comparison');
end

function [soc, timeIdx] = getSocVal(vals, busIdx)
G = vals.G;
result = vals.result.x;
Const = vals.Const;
nodeIdx = G.nodes(:,Const.node.idx.BUS) == busIdx;
timeIdx = G.nodes(nodeIdx,Const.node.idx.TIME);
yIdx = G.nodes(nodeIdx, Const.node.idx.YSOC);
soc = result(yIdx);
end