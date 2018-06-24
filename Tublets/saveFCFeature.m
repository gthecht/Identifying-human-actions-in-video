function [] = saveFCFeature(FCfeatureCell, Times, labels, vidID, saveDir)
% saves the cell of feature vectors, with the labels, and also with the
% times of the segments to a table with the name of vidID:
FCTrainingTable = table(FCfeatureCell, Times, labels, ...
                'VariableNames', {'FCfeaturesVector', 'Time', 'label'});
tableName = [saveDir, '\', vidID, '_FCTable'];
save(tableName, 'FCTrainingTable');
end

