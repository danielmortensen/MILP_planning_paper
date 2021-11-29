function allUnitTest
try
    unitTestGetCDemandOnPeak;
catch
    warning('failed on-peak demand unit test');
end
try
    unitTestGetCDemand;
catch
    warning('failed demand unit test\n');
end
try
    unitTestGetCDSoc;
catch
    warning('failed dsoc unit test\n');
end
try
    unitTestGetCGroup;
catch
    warning('failed group unit test\n');
end
try
    unitTestGetCIncidence;
catch
    warning('failed incidence unit test');
end
try
    unitTestGetCMinSoc;
catch
    warning('failed min soc unit test');
end
try
    unitTestGetCSoc;
catch
    warning('failed soc unit test');
end
end