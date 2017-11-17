%% Gilad 17.11.17
%  Turn labels.txt into a table of labels:
clear; clc;
labelsTxt = textread('labels.txt', '%q');
labelsTxt = reshape(labelsTxt, 9, [])';

labelsTable = table(labelsTxt(:,4), labelsTxt(:,6), labelsTxt(:,8),...
    'VariableNames', {'name', 'label_id', 'type'});
% writetable(labelsTable);