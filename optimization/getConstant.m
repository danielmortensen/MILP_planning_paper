function Constant = getConstant(Scenario)
Constant.node.type.REST = 0;
Constant.node.type.START = 1;
Constant.node.type.DAY_CHARGE = 2;
Constant.node.type.NGT_CHARGE = 3;
Constant.node.type.MOUNT = 4;
Constant.node.type.DISMOUNT = 5;
Constant.node.type.FUSE_POST = 6;
Constant.node.type.FUSE_PRE = 7;
Constant.schedule.type.DAY = 1;
Constant.schedule.type.NIGHT = 2;
Constant.charge.MAX_CHARGE = Scenario.maxBatteryCharge;
Constant.charge.nDayRate = Scenario.nDayChargeRate;
Constant.charge.nNightRate = Scenario.nNightChargeRate;
Constant.charge.R_DAY = Scenario.dayChargeRates;
Constant.charge.R_NIGHT = Scenario.nightChargeRates;


Constant.node.idx.Y = 1;
Constant.node.idx.X = 2;
Constant.node.idx.BUS = 3;
Constant.node.idx.YSOC = 4;
Constant.node.val.SOC = 5;
Constant.node.idx.GROUP = 6;
Constant.node.idx.TIME = 7;
Constant.node.idx.TYPE = 8;

Constant.edge.type.REST = 0;
Constant.edge.type.MOUNT = 1;
Constant.edge.type.DISMOUNT = 2;
Constant.edge.type.DAY_CHARGE = 3;
Constant.edge.type.NGT_CHARGE = 4;
Constant.edge.pType.OFF_PEAK = 1;
Constant.edge.pType.ON_PEAK = 2;

Constant.edge.idx.YEDGE = 1;
Constant.edge.idx.YDSOC = 2;
Constant.edge.idx.TYPE = 3;
Constant.edge.idx.GROUP = 4;
Constant.edge.idx.START_NODE = 5;
Constant.edge.idx.END_NODE = 6;
Constant.edge.idx.BUS = 7;
Constant.edge.idx.TIME = 8;
Constant.edge.idx.WEIGHT = 9;
Constant.edge.idx.DECISION = 10;
Constant.edge.idx.RATE = 13;
Constant.edge.val.DSOC = 11;
Constant.edge.idx.PEAK_TYPE = 12;
end