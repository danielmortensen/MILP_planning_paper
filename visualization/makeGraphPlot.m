function makeGraphPlot(G, result, Const, id)
           
% plot routes through graph
nBus = G.param.base.nBus;
figure; hold on; xlim([0,G.param.nTime]);
for iBus = 1:nBus
    % get edges for the current bus
    isCurrBus = G.edges(:,Const.edge.idx.BUS) == iBus;
    
    % get edges that are currently in use
    yIdx = G.edges(isCurrBus,Const.edge.idx.YEDGE);    
    isInUse = logical(result(yIdx));
    
    currEdge = G.edges(isCurrBus,:);
    currEdge = currEdge(isInUse,:);
    startIdx =  currEdge(:,Const.edge.idx.START_NODE);
    endIdx = currEdge(:,Const.edge.idx.END_NODE);
    nCurrEdge = size(startIdx,1);
    for iCurrEdge = 1:nCurrEdge
        sX = G.nodes(startIdx(iCurrEdge), Const.node.idx.X);
        sY = G.nodes(startIdx(iCurrEdge), Const.node.idx.Y);
        eX = G.nodes(endIdx(iCurrEdge), Const.node.idx.X);
        eY = G.nodes(endIdx(iCurrEdge), Const.node.idx.Y);
        cIdx = currEdge(iCurrEdge,Const.edge.idx.RATE);
        if isnan(cIdx)
            color = [0 0 0 0.4]; % black, transparency at 0.4
            linewidth = 0.01;
        else
            timeIdx = currEdge(iCurrEdge,Const.edge.idx.TIME);            
            if G.chargeType(timeIdx) == Const.schedule.type.NIGHT
                rate = Const.charge.R_NIGHT(cIdx);
                color = getColor(rate);
            else
                rate = Const.charge.R_DAY(cIdx);
                color = getColor(rate);
            end
            linewidth = 2;
        end
        plot([sX;eX],[sY;eY] ,'color',color,'linewidth',linewidth);
    end    
end

% plot node locations
x = G.nodes(:,Const.node.idx.X);
y = G.nodes(:,Const.node.idx.Y);
scatter(x,y,2,[0 0.4470 0.7410],'filled');

% create dummy legend placeholders
nDayRate = 4;
h = zeros([nDayRate + 2,1]);
dayCharges = [-0.0030 -0.0120 -0.0210 -0.0300];
for iRate = 4:-1:1
    rate = dayCharges(iRate);
    h(iRate) = plot(NaN, NaN, 'color' ,getColor(rate));
end
h(end - 1) = plot(NaN, NaN, 'color' ,'black');

% add shading for on-peak time intervals
nBus = G.param.base.nBus;
dTime = G.param.base.dTime;
h(end) = addOnPeakShading(gca,nBus,0,dTime);

% update x axis for time
nTime = G.param.nTime;
addTimeAxis(gca,nTime,24*60);

% add legend
for iLegend = 4:-1:1 
    val = dayCharges(iLegend);
    legendVal{iLegend} = sprintf('charge rate: %0.3f',dayCharges(iLegend));
end
legendVal{end + 1} = sprintf('charge rate: %0.2f',0);
legendVal{end + 1} = 'On Peak Time Interval';
legend(h,legendVal);
      
% add title
titleStr = "Graph Based Solution";
if nargin == 4
   titleStr = titleStr + " for " + id;
end
title(titleStr);
end

function color = getColor(val)
dayCharges = fliplr([-0.0030 -0.0120 -0.0210 -0.0300]);
colors = {[0.9290, 0.6940, 0.1250],... %yellow
               [0.8500, 0.3250, 0.0980],... %orange
               [0.6350, 0.0780, 0.1840],... %red
               [0.4660, 0.6740, 0.1880],... %green
               };
try
    color = colors{isAlmost(dayCharges,val, 1e-10)};
catch
    fprintf('temp\n');
end
end

function result = isAlmost(val1, val2, tol)
    result = abs(val1 - val2) < tol;
end