function [result, Const, G] = solveScenario(scenario)
Const = getConstant(scenario);
pDay= getDayProfile(scenario, Const);
G = formGraph(pDay, Const);
if scenario.chargeAtNight
    G = appendNightGraph(G, Const);
end
G = computeConstraint(G, Const);
[model, param] = getGurobiModel(G);
if contains(G.param.base.minimization,'Max')
    model.obj = -model.obj;
end
param.dualreductions = 0;
param.TimeLimit = inf;
result = gurobi(model,param);
end