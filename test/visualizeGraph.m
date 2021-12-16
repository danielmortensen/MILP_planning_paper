function visualizeGraph(G, Const, includeCurves)

if nargin == 2
    includeCurves = false;
end
BUS = Const.edge.idx.BUS;
START_NODE = Const.edge.idx.START_NODE;
END_NODE = Const.edge.idx.END_NODE;
edges = G.edges;
nodes = G.nodes;
nEdge = G.param.nEdge;
nBus = G.param.nBus;
nodeColor = [0.3010 0.7450 0.9330];
nodeRadius = 0.08;

% initialize for indexing
colors = {"red","blue",[0.4660 0.6740 0.1880]};

% plot nodes
figure; hold on; 
scatter(G.nodes(:,Const.node.idx.X),...
        G.nodes(:,Const.node.idx.Y), 50, nodeColor, 'filled');

% add curved lines above
if includeCurves
   plotCurves();
else
    arrowStart = zeros([nEdge,2]);
    arrowEnd = zeros([nEdge,2]);
end

% plot edges
for iEdge = 1:nEdge
    
    % get color for bus
    iColor = edges(iEdge, BUS);
    if isnan(iColor)
        iColor = 3;
    end
    
    try
    n = [nodes(edges(iEdge,START_NODE),:);...
         nodes(edges(iEdge,END_NODE),:)];
     
    
    start = n(1,[2,1]); stop = n(2,[2,1]);
    if ~includeCurves
        diff = n(1,:) - n(2,:);
        diff = diff([2,1]);
        arrowDelta = getArrowDelta(diff,nodeRadius);
        start = start - arrowDelta;
        stop = stop + arrowDelta;
        arrowStart(iEdge,:) = start;
        arrowEnd(iEdge,:) = stop;
        arrow(start,stop,'length',3,'baseAngle',30,'tipAngle',10,'color',colors{iColor});
    else
        plot([start(1);stop(1)],[start(2);stop(2)],'color',colors{iColor});
    end
    
    catch err
        break;
    end
end
arrow(arrowStart(1,:),arrowEnd(2,:),'length',3,'baseAngle',30,'tipAngle',10,'color',colors{3});
ylabel('Bus Index'); yticks(0:nBus);
xlabel('Time Index');
set(gcf,'Units','Inches');
set(gcf,'Position',[10,10,7,4]); shg; 



end

function arrowDelta = getArrowDelta(delta, radius)
theta = atan2(delta(2),delta(1));
arrowDelta = radius*[cos(theta) sin(theta)];
end

function plotCurves()
d = [0 0.07 0]';
x1 = [2 2.5 3]';
x1Int = [2:0.001:3]';
x2 = [5 5.5 6]';
x2Int = [5:0.001:6]';
y1 = [2 2 2]';
y2 = [1 1 1]';

% top left functions
f11Top = fit(x1,y1 + d,'poly2');
f11Btm = fit(x1,y1 - d,'poly2');
plot(x1Int,f11Top(x1Int),'color','blue');
plot(x1Int,f11Btm(x1Int),'color','blue');
plot(x1,y1,'color','blue');

% bottom left functions
f21Top = fit(x1,y2 + d,'poly2');
f21Btm = fit(x1,y2 - d,'poly2');
plot(x1Int,f21Top(x1Int),'color','red');
plot(x1Int,f21Btm(x1Int),'color','red');
plot(x1,y2,'color','red');

% top right functions
f12Top = fit(x2,y1 + d,'poly2');
f12Btm = fit(x2,y1 - d,'poly2');
plot(x2Int,f12Top(x2Int),'color','blue');
plot(x2Int,f12Btm(x2Int),'color','blue');
plot(x2,y1,'color','blue');

% bottom right functions
f22Top = fit(x2,y2 + d,'poly2');
f22Btm = fit(x2,y2 - d,'poly2');
plot(x2Int,f22Top(x2Int),'color','red');
plot(x2Int,f22Btm(x2Int),'color','red');
plot(x2,y2,'color','blue');
end
