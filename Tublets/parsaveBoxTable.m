function [] = parsaveBoxTable(tablesdir, boxTable,boxTableName)
% saves boxTable from within the parfor.
% save table to tablesdir:
% first the name:
save([tablesdir,'\',boxTableName], 'boxTable');
end

