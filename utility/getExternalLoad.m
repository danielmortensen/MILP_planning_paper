function [load, time] = getExternalLoad(file, timestep, tStart, nTime, syncTime)
data = readtable(file);
if size(data,2) == 3
    time = table2array(data(:,2));
    power = table2array(data(:,3));
else
    time = table2array(data(:,1));
    power = table2array(data(:,2));
end
timeConv = convertTo(time,'posixtime');
timeConv = timeConv - timeConv(1);
otFs = 1/(timestep*60); %convert minutes to seconds

% pre-avarage
% power = conv(power,ones([150,1])/150,'same'); 150 is (bad) magic number =
% 60*timestep/2.03 (input samples per second)

[powerResampled, timeResampled] = resample(power,timeConv,otFs,'pchip');
if syncTime
    iStart = round(tStart/timestep) + 1;
else
    iStart = 70;
end
iEnd = iStart + nTime - 1;
powerResampled1 = powerResampled(iStart:iEnd);
time = timeResampled(iStart:iEnd);
%if range(powerResampled1) ~= 0 && range(power) ~= 0
%    load = (powerResampled1 - min(powerResampled1))/range(powerResampled1)*range(power) + min(power);
%else
load = powerResampled1;
%end
end
