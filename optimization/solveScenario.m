function [result, Const, G] = solveScenario(scenario)
Const = getConstant(scenario);
pDay= getDayProfile(scenario, Const);
G = formGraph(pDay, Const);
if scenario.chargeAtNight
    G = appendNightGraph(G, Const);
end
G = computeConstraint(G, Const);
[model, param] = getGurobiModel(G);
param.dualreductions = 0;
...param.TimeLimit = 10;
result = gurobi(model,param);
end