% PLEASE LOAD boxTable AND v BEFORE RUNNING THE SCRIPT AS "boxTable" and
% "v" !!!

% boxTable = load(...);
% v = VideoReader(...);

maxBoxTable = maxScoreFromboxTable(boxTable);
sz = [224, 224];
tStart = 0;
tLen = 1;
[Tublets, Times] = segTubeletCreatorPresentation(boxTable, maxBoxTable,...
                   v, sz, tStart, tLen);





