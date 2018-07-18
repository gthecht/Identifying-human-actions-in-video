function [maxBoxTable] = maxScoreFromboxTable(boxTable)

len = size(boxTable, 1);
maxBoxTable = boxTable;
junkBox = [0 0 1 1];

for jj = 1:len
    if (~isempty(boxTable.score{jj}))
        [val, pos] = max(boxTable.score{jj});
        maxBoxTable.bbox{jj} = boxTable.bbox{jj}(pos, :);
        maxBoxTable.score{jj} = val;
    else
        maxBoxTable.bbox{jj} = junkBox;
        maxBoxTable.score{jj} = 0;
    end
end


end

