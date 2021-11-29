function makeSocChart(G, result, Const, plotByPercentage, id)
maxSoc = Const.charge.MAX_CHARGE;
nBus = G.param.base.nBus;
figure; hold on;
for iBus = nBus:-1:1
   nodeIdx = G.nodes(:,Const.node.idx.BUS) == iBus;
   timeIdx = G.nodes(nodeIdx,Const.node.idx.TIME);
   yIdx = G.nodes(nodeIdx, Const.node.idx.YSOC);
   if plotByPercentage
       soc = result(yIdx)/maxSoc*100; % convert to percent soc
   else
       soc = result(yIdx);
   end
   h(iBus) = plot(timeIdx, soc);  
   legendVal{iBus} = sprintf('Bus %i',iBus);
end
if plotByPercentage
    h(end + 1) = yline(G.param.base.minSoc/maxSoc*100,'--');
    ylabel('Percent Bus State of Charge');
    ylim([0,100]);
else
    h(end + 1) = yline(G.param.base.minSoc,'--');
    ylabel('kWh Bus State of Charge');
    ylim([0, maxSoc]);
end
xlabel('Time');
legendVal{end + 1} = 'Minimum SOC Limit';
legend(h, legendVal,'Location','southwest');
nTime = G.param.nTime;
addTimeAxis(gca,nTime,24*60);
titleStr = "Bus State of Charge";
if nargin == 5
    titleStr = titleStr + " for " + string(id);
end
title(titleStr);
end
