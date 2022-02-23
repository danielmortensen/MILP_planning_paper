function makeTotalPowerPlot(G, result, id, latexFilePath, Const)

% compute values for facilities charge over time
busFacilitiesSelect = toSparse(G.Constraint.demand.A, G.param.nSolution);
busFacilitiesSelect(:,end - 1) = 0;
demandFacilities = busFacilitiesSelect*result - G.Constraint.demand.b;
[~, maxFacilitiesIdx] = max(demandFacilities);
maxFacilities = result(end - 1);

% compute values for on-peak demand charge over time
busDemandSelect = toSparse(G.Constraint.demandOnPeak.A, G.param.nSolution);
busDemandSelect(:,end) = 0;
demandOnPeak = zeros([G.param.nTime,1]);
isOnPeak = logical(G.param.isOnPeak);
demandOnPeak(isOnPeak) = busDemandSelect*result - G.Constraint.demandOnPeak.b;
[~, maxOnPeakIdx] = max(demandOnPeak);
maxOnPeak = result(end);

% plot values
figure; hold on; 
plot(demandFacilities);
plot(demandOnPeak);
yline(maxFacilities,'r');
yline(maxOnPeak,'--c');

% add on peak shading
maxVal = max(maxOnPeak, maxFacilities);
minVal = min(demandFacilities);
dTime = G.param.base.dTime;
addOnPeakShading(gca,maxVal, minVal, dTime);

% update x axis 
nTime = G.param.nTime;
addTimeAxis(gca,nTime,24*60);

% add legend values
legend('Facilities','On Peak', 'Max Facilities', 'Max On Peak',...
       'On Peak Time Interval','Location','southwest');
   
titleStr = "Total Required Power";
if nargin == 3
    titleStr = titleStr + " for " + id;
end
title(titleStr);
if nargin == 5
    % get histogram values for different charge types
    edgeIdx = G.edges(:,Const.edge.idx.TYPE) == Const.edge.type.DAY_CHARGE;
    dayEdge = G.edges(edgeIdx,:);
    nCharge = numel(unique(dayEdge(:,Const.edge.idx.RATE)));
    C = zeros([nCharge, G.param.nSolution]);
    nEdge = size(dayEdge,1);
    for iEdge = 1:nEdge
        dsocIdx = dayEdge(iEdge,Const.edge.idx.YEDGE);
        rateIdx = dayEdge(iEdge,Const.edge.idx.RATE);
        C(rateIdx,dsocIdx) = 1;
    end
    counts = C*result
    aBar = exp(Const.charge.R_DAY*G.param.base.dTime)
end
if nargin == 4
    datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');
    nMax = max([numel(demandOnPeak) numel(demandFacilities)]);
    onPeakOut = zeros([nMax,1]);
    facilitiesOut = zeros([nMax,1]);
    maxFacilitiesOut = zeros([nMax,1]);
    maxOnPeakOut = zeros([nMax,1]);
    onPeakOut(1:numel(demandOnPeak)) = demandOnPeak;
    facilitiesOut(1:numel(demandFacilities)) = demandFacilities;
    maxFacilitiesOut(maxFacilitiesIdx) = maxFacilities;
    maxOnPeakOut(maxOnPeakIdx) = maxOnPeak;
    time = datetime(0,0,0,0,0,(0:dTime*60:60*60*24 - 1))';
    data = table(onPeakOut, facilitiesOut, maxFacilitiesOut, maxOnPeakOut, time);
    writetable(data, latexFilePath,'Delimiter',',');
    
    
end
end
