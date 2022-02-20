function [result, Const, G] = runSimulation(scenario, simId)
[result, Const, G] = solveScenario(scenario);
if strcmp(scenario.minObjective,'baseline')
    [result.x, G] = convertToSchedule8(result.x, G, Const);
end
save(simId + ".mat",'G','result','Const');
makePieChart(G, result.x, simId);
makeSocChart(G, result.x, Const, false, simId);
makeGraphPlot(G, result.x, Const, simId);
makeTotalPowerPlot(G, result.x, simId);
makePowerPlot(G, result.x, simId);
makeTotalEnergyPlot(G, result.x, Const, simId);
end

function [result, G] = convertToSchedule8(result, G, Const)
facilitiesA = toSparse(G.Constraint.demand.A,G.param.nSolution);
facilitiesA(:,end-1:end) = 0;
facilities = max(facilitiesA*result - G.Constraint.demand.b);

onPeakA = toSparse(G.Constraint.demandOnPeak.A,G.param.nSolution);
onPeakA(:,end-1:end) = 0;
onPeak = max(onPeakA*result - G.Constraint.demandOnPeak.b);

result(end - 1) = facilities;
result(end) = onPeak;

G.param.base.minimization = 'MinSchedule8';
G.Constraint.objective = getObjective(G,Const);
end

