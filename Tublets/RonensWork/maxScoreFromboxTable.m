function [maxBoxTable] = maxScoreFromboxTable(boxTable)

len = size(boxTable, 1);
maxBoxTable = boxTable;

for jj = 1:len
    if (~isempty(boxTable.score{jj}))
        [val, pos] = max(boxTable.score{jj});
        maxBoxTable.bbox{jj} = boxTable.bbox{jj}(pos, :);
        maxBoxTable.score{jj} = val;
    else
        maxBoxTable.bbox{jj} = boxTable.bbox{jj};
        maxBoxTable.score{jj} = boxTable.score{jj};
    end
end


end

