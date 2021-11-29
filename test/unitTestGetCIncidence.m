function unitTestGetCIncidence()
addpath('../');
result1 = testScenario(@()getScenario1);
result2 = testScenario(@()getScenario2);
result3 = testScenario(@()getScenario3);
result4 = testScenario(@()getScenario4);
result5 = testScenario(@()getScenario5);
result6 = testScenario(@()getScenario6);
result7 = testScenario(@()getScenario7);
assert(all([result1, result2, result3, result4, result5, result6, result7]));
end

function result = testScenario(scenario)
[G, Const, solution] = scenario();
nSolution = numel(solution);
[b, A] = getCIncidence(G, Const);
A = toSparse(A, nSolution);
bOut = A*solution;
result = all(b == bOut);
end