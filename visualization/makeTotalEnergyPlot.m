function makeTotalEnergyPlot(G, result, Const, id)
uncontrolledEnergy = G.extern.load;
nTime = G.param.nTime;
busEnergy = zeros([nTime,1]);
for iTime = 1:nTime
    edgeSelectIdx = G.edges(:,Const.edge.idx.TIME) == iTime;
    edgeDsocIdx = G.edges(edgeSelectIdx,Const.edge.idx.YDSOC);
    edgeDsocIdx = edgeDsocIdx(~isnan(edgeDsocIdx));
    busEnergy(iTime) = sum(result(edgeDsocIdx));
end
totalEnergy = busEnergy + uncontrolledEnergy;
figure; hold on;
plot(busEnergy);
plot(uncontrolledEnergy,'color',[0.9290, 0.6940, 0.1250, 0.5]);
plot(totalEnergy,'color',[1, 0, 0, 0.3]);
addTimeAxis(gca, nTime, 60*24);
maxVal = max([busEnergy(:); uncontrolledEnergy(:); totalEnergy(:)]);
minVal = min([busEnergy(:); uncontrolledEnergy(:); totalEnergy(:)]);
dTime = G.param.base.dTime;
addOnPeakShading(gca, maxVal, minVal, dTime);
legend('Bus Energy', 'Uncontrolled Load Energy', 'Total Energy', 'On Peak Time Interval');
titleStr = "Total Energy Expended";
if nargin == 4
    titleStr = titleStr + " for " + id;
end
title(titleStr);
end
