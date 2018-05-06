function [dataTable, countCut] = FindCutScene(thresh, edges)
% This function intends to detect either in some video there is some cut
% scene or not. if it does, we take only the part before the cut if it
% happened after the middle frame, and the second part if it happened
% before that frame.
% At the end of this function the output will be as the following table:
% | vidName | Folder | isCut | Lentgh (num of    | First frame   | New GT  
% |         |        |       | frames in         | (usually 1)   | position
% |         |        |       | original video)   |               |         
% -------------------------------------------------------------------------
% |         |        |       |                   |               |     
% |         |        |       |                   |               |        
% |         |        |       |                   |               |        
% This is  the output dataTable. the output countCut counts the number of
% cuts we detected.
% thresh indicates how we definr a cut scene (x-med)/std>thresh.
% edges indicates the number of bins in the hisogram.
% Good values are tresh=6, edges=8.
prompt = 'Choose the directory from which you want to check it''s videos';
Qtitle = 'Input';
answer = inputdlg(prompt,Qtitle);
addpath(answer{1});
list = dir(answer{1});
dataTable = struct2table(list);
dataTable(dataTable.isdir==1, :) = [];
dataTable = table(dataTable.name, dataTable.folder, dataTable.isdir,...
    'VariableNames', {'vidName','Folder','isCut'});
countCut = 0;
gradSum = [];
med = [];
for ii = 1:length(dataTable.isCut)
    imNum = 0;
    h = [];
    histGrad = [];
    v = VideoReader(dataTable.vidName{ii});
    sz = v.Width * v.Height;    % size of the frame in the the video
    while hasFrame(v)   % For a single video
    video = rgb2gray(readFrame(v));
    N = histcounts(video, edges) / sz;  % Stochastic normalized histogram
                                        % of the frame.
    h = [h; N]; % concatenate the histogram bins one under the other.
    end
    for jj = 1:edges
        currColGrad = h(2:end, jj) - h(1:end-1, jj); % neglect first frame.
        histGrad = [histGrad, currColGrad]; 
    end
    med = median(histGrad);
    stanDev = std(histGrad);
    x = histGrad;
    val = (x - med) ./ stanDev;
    cutted = (abs(val) > thresh);
    cuttedSum = sum(cutted, 2);
    iscutted = (cuttedSum >= edges/4);
    iscuttedSum = sum(iscutted);
    if (iscuttedSum)
        dataTable.isCut(ii) = 1;
        countCut = countCut + 1;
    end
end
end

