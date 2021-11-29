function profile = getDayProfile(scenario, Const)
base.dTime = scenario.dTime; %minutes
base.fLoadProfile = scenario.fExternalLoad;
base.nBus = scenario.nBus;
base.minimization = scenario.minObjective; % 'demand', 'consumption', 'all', 'schedule8'
base.minSoc = scenario.socLowerBound;
profile.base = base;
profile.speed = 5.433*60; %meters/minute
profile.nCharger = scenario.nOverheadCharger;
profile.dDischarge = 0.0002699; %soc/m or dsoc/dx
profile.fFleetProfile = scenario.fRoute;
profile.scheduleType = Const.schedule.type.DAY;
end
