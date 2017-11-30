%% Gilad 17.11.17
%  Turn labels.txt into a table of labels:
clear; clc;
labelsTxt = textread('labels.txt', '%q');
labelsTxt = reshape(labelsTxt, 9, [])';

labelsTable = table(labelsTxt(:,4), labelsTxt(:,6), labelsTxt(:,8),...
    'VariableNames', {'name', 'label_id', 'type'});
% writetable(labelsTable);

%% Turn table to rows text:
fileID = fopen('labelsNew.txt', 'w');
 for ii = 1:length(labelsTxt)
     fprintf(fileID, 'label {\r\n');
     fprintf(fileID, 'name: "%s"\r\n', labelsTable.name{ii});
     fprintf(fileID, 'label_id: %s\r\n', labelsTable.label_id{ii});
     fprintf(fileID, 'label_type: %s\r\n', labelsTable.type{ii});
     fprintf(fileID, '}\r\n');
 end
 fclose(fileID);
     