function [outTable] = createOutTable(testOutcome, testTable, labelsName, nTest, labNum)
% testOutcome comes as [bbox, score, label], we want to turn into into a
% table that will look like testTable:
emptyCell = cell(nTest,2*labNum);
outTable = [table(testTable.names), emptyCell];
labelsScore = strcat(labelsName, 'Score');
outTable.Properties.VariableNames = [{'names'}; labelsName; labelsScore];
for ii = 1:nTest
    currLabs = cellstr(testOutcome(ii,:).label{:});
    labsIndx = cellfun(@(X) find(ismember(labelsName, X)), currLabs, 'UniformOutput', false);
    for jj = 1:length(labsIndx)
        outTable{ii, labsIndx{jj}+1} = {[outTable{ii, labsIndx{jj} + 1}{:};...
            testOutcome(ii,:).bbox{:}(jj,:)]};
        outTable{ii, labsIndx{jj}+1+labNum} = {[outTable{ii, ...
            labsIndx{jj}+1+labNum}{:}; testOutcome(ii,:).score{:}(jj,:)]};
    end
end
end

