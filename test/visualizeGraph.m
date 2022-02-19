function visualizeGraph(G, Const)
BUS = Const.edge.idx.BUS;
START_NODE = Const.edge.idx.START_NODE;
END_NODE = Const.edge.idx.END_NODE;
edges = G.edges;
nodes = G.nodes;
nEdge = G.param.nEdge;

% initialize for indexing
colors = ["red","blue","green"];
figure; hold on; 
for iEdge = 1:nEdge
    
    % get color for bus
    iColor = edges(iEdge, BUS);
    if isnan(iColor)
        iColor = 3;
    end
    try
    n = [nodes(edges(iEdge,START_NODE),:);...
         nodes(edges(iEdge,END_NODE),:)];
    
    plot(n(:,2), n(:,1), 'color',colors(iColor));
    catch err
        break;
    end
end
end
