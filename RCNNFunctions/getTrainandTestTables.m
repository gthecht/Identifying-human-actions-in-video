function [trainTable,testTable] = getTrainandTestTables()
% Choose the train table and the test tables in the files:

%% Pick train table:
[list, listPath] = uigetfile('*.csv', 'Select training data');
csvID    = fopen([listPath, list]);
avaTrain = textscan(csvID,'%s %f %f %f %f %f %f', 'Delimiter', ',');
fclose(csvID);
trainTable = table(avaTrain{1}, avaTrain{2}, avaTrain{3}, avaTrain{4}, ...
    avaTrain{5}, avaTrain{6}, avaTrain{7}, ...
    'VariableName', {'videoID', 'middleFrameTimeStamp', 'topLeft_x',...
    'topLeft_y', 'bottomRight_x', 'bottomRight_y', 'actionLabel'});
%% Pick test table:
[list, listPath] = uigetfile('*.csv', 'Select test data');
csvID   = fopen([listPath, list]);
avaTest = textscan(csvID,'%s %f %f %f %f %f %f', 'Delimiter', ',');
fclose(csvID);
testTable = table(avaTest{1}, avaTest{2}, avaTest{3}, avaTest{4}, ...
    avaTest{5}, avaTest{6}, avaTest{7}, ...
    'VariableName', {'videoID', 'middleFrameTimeStamp', 'topLeft_x',...
    'topLeft_y', 'bottomRight_x', 'bottomRight_y', 'actionLabel'});
end

