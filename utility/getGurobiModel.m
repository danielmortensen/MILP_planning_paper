function [model, params, debug] = getGurobiModel(Graph)

% unpack relevent parameters
nSolution = Graph.param.nSolution;

Aeq1 = toSparse(Graph.Constraint.incidence.A, nSolution);
beq1 = Graph.Constraint.incidence.b;
Aeq2 = toSparse(Graph.Constraint.Soc.A, nSolution);
beq2 = Graph.Constraint.Soc.b;
Ale1 = toSparse(Graph.Constraint.group.A, nSolution);
ble1 = Graph.Constraint.group.b;
Ale2 = toSparse(Graph.Constraint.DSoc.A, nSolution);
ble2 = Graph.Constraint.DSoc.b;
Ale3 = toSparse(Graph.Constraint.min.A, nSolution);
ble3 = Graph.Constraint.min.b;
Ale4 = toSparse(Graph.Constraint.demand.A, nSolution);
ble4 = Graph.Constraint.demand.b;
Ale5 = toSparse(Graph.Constraint.demandOnPeak.A, nSolution);
ble5 = Graph.Constraint.demandOnPeak.b;
Ale6 = toSparse(Graph.Constraint.SocEnd.A, nSolution);
ble6 = Graph.Constraint.SocEnd.b;
w = Graph.Constraint.objective;

% if contains(Graph.param.base.minimization,'Max')
%     dmd = '<';
% %     Ale4 = -Ale4;
% %     ble4 = -ble4;
% %     Ale5 = -Ale5;
% %     ble5 = -ble5;
% else
%     dmd = '<';
% end

model.vtype = [Graph.param.varType;...
               repmat('C',[2,1])];
model.A = [Aeq1;...
           Aeq2;...
           Ale1;...
           Ale2;...
           Ale3;...
           Ale4;...
           Ale5;...
           Ale6,...
           ];
model.rhs = [beq1;...
             beq2;...
             ble1;...
             ble2;...
             ble3;...
             ble4;...
             ble5;...
             ble6,...
             ];

    
model.sense = [
    repmat('=',[size(Aeq1,1),1]);
    repmat('=',[size(Aeq2,1),1]);
    repmat('<',[size(Ale1,1),1]);
    repmat('<',[size(Ale2,1),1]);
    repmat('<',[size(Ale3,1),1]);
    repmat('<',[size(Ale4,1),1]);
    repmat('<',[size(Ale5,1),1]);
    repmat('<',[size(Ale6,1),1]);
    ];
model.obj = w;
model.ub = Graph.param.upperBound;
% model.lb = Graph.param.lowerBound;
params.TimeLimit = Inf;
debug.Ale4 = Ale4;
debug.ble4 = ble4;
end
