function addTimeAxis(ax, nTimeIdx, nMinutes)
nLabels = 7;
labelIdx = round(linspace(1,nTimeIdx,nLabels));
time = minutes((0:nTimeIdx - 1)/nTimeIdx*nMinutes);
time.Format = 'hh:mm';
time = cellstr(time);
xticks(ax, labelIdx);
xticklabels(ax, time(labelIdx));
end