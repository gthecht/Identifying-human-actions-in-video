function [done] = save2Temp(fileName, filePath, saveVars)
% Saves workspace in filePath, with the name of fileName_%date
saveName = [filePath, '\', fileName, '_', date];
save(saveName, saveVars);
done = 1;
end