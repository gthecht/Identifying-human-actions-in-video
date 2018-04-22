function [done] = save2Temp(fileName, filePath)
% Saves workspace in filePath, with the name of fileName_%date
saveName = [filePath, '\', fileName, '_', date];
save(saveName);
done = 1;
end