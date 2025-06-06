function [loadData, time] = getExternalLoad(file, timestep, tStart, nTime, syncTime)
try
    data = readtable(file);
    if size(data,2) == 3
        time = table2array(data(:,2));
        power = table2array(data(:,3));
    else
        time = table2array(data(:,1));
        power = table2array(data(:,2));
    end
    timeConv = convertTo(time,'posixtime');

catch
    data = load(file);
    power = data.mu;
    nData = numel(power);
    time = datetime(2022,1,1) + seconds((0:nData - 1)/nData*3600*24);
    timeConv = convertTo(time,'posixtime');
end
timeConv = timeConv - timeConv(1);
otFs = 1/(timestep*60); %convert minutes to seconds

[powerResampled, timeResampled] = resample(power,timeConv,otFs,'pchip');
if syncTime
    iStart = round(tStart/timestep) + 1;
else
    iStart = 70;
end
iEnd = iStart + nTime - 1;
try
    powerResampled1 = powerResampled(iStart:iEnd);
    time = timeResampled(iStart:iEnd);
catch
    powerResampled1 = powerResampled(iStart:iEnd-1);
    powerResampled1 = [powerResampled1 0];
    time = timeResampled(iStart:iEnd - 1);
    dTime = time(end) - time(end-1);
    time = [time time(end) + dTime];
end
loadData = powerResampled1;
end
