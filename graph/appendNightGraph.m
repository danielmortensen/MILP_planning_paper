function G = appendNightGraph(dayGraph, Const)

% create night profiles
[pG0, pG2] = formNightProfiles(dayGraph, dayGraph.param.base, Const);

% form graphs for night use
G0 = formGraph(pG0, Const);
G2 = formGraph(pG2, Const);

% append night graphs to day graph
GList = [G0, dayGraph, G2];
G = combineModels(GList, Const);
end
