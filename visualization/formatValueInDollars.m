function S = formatValueInDollars(input)
S = sprintf('%0.2f',input); 
T(1:length(S)) = char(0);
T(strfind(S, '.') - 4:-3:1) = ',';  % [EDITED: -3 -> -4]
S = [S; T];
S = reshape(S(S ~= 0), 1, []);
end