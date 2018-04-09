function [testBoxes] = createTestBoxesTable(nTest, testTable, labelsName)
testBoxes = table(cell(nTest, 1));
testBoxes.Properties.VariableNames = {'bbox'};
for ii = 1:nTest
    currRow = testTable(ii,:);
    row2Cell = currRow{:,2:end};
    testBoxes.bbox{ii} = cell2mat(reshape(row2Cell, [], 1));
    labelSizes = cellfun(@(X) size(X, 1), row2Cell);
    testBoxes.labels{ii} = repelem(labelsName, labelSizes);
end
end

