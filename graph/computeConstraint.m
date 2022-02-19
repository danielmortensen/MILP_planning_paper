function G = computeConstraint(G, Const)
[beq1, Aeq1] = getCIncidence(G, Const);

[ble1, Ale1] = getCGroup(G, Const);

[ble2, Ale2] = getCDSoc(G, Const);

[beq2, Aeq2, ble6, Ale6] = getCSoc(G, Const);

[ble3, Ale3] = getCMinSoc(G, Const);

[ble4, Ale4, load, time] = getCDemand(G,Const);

[ble5, Ale5] = getCDemandOnPeak(G, Const);

C.incidence.A = Aeq1;
C.incidence.b = beq1;
C.group.A = Ale1;
C.group.b = ble1;
C.DSoc.A = Ale2;
C.DSoc.b = ble2;
C.Soc.A = Aeq2;
C.Soc.b = beq2;
C.SocEnd.A = Ale6;
C.SocEnd.b = ble6;
C.min.A = Ale3;
C.min.b = ble3;
C.demand.A = Ale4;
C.demand.b = ble4;
C.demandOnPeak.A = Ale5;
C.demandOnPeak.b = ble5;
G.Constraint = C;
G.extern.load = load;
G.extern.time = time;
G.Constraint.objective = getObjective(G, Const);

end
