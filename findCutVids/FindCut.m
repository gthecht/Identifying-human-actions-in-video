function [dataTable, countCut] = FindCut(thresh)
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
% This is  the output dataTable.
% The output countCut counts the number of cuts we detected.
% Good value for thresh is 0.7.
prompt = 'Choose the directory from which you want to check it''s videos';
Qtitle = 'Input';
answer = inputdlg(prompt,Qtitle);
addpath(answer{1});

% taking all the videos and creating a table from them
list = dir(answer{1});
T = struct2table(list);
T(T.isdir==1, :) = [];
n = length(T.isdir);    % Number of videos.

% Create the data table
dataTable = table(T.name, T.folder, zeros(n,1), zeros(n,1), ones(n,1),...
    zeros(n,1),zeros(n,1),'VariableNames', {'vidName','Folder','isCut','Length',...
    'FirstFrame','GTFrameNum','minssimVal'});

countCut = 0;   % Counts the number of cut videos

for ii=1:n
    disp(ii)
    frames = [];
    len = 0;
    v = VideoReader(dataTable.vidName{ii});
    ssimVal = [];
    
    while(hasFrame(v))
        len = len + 1;
        frames(:, :, len) = rgb2gray(readFrame(v));
    end
    
    dataTable.Length(ii) = len;
    dataTable.GTFrameNum(ii) = ceil(len/2);

    for jj=1:(len-1)
        ref = frames(:,:,jj);
        currssimVal = getMSSIM(frames(:,:,jj+1), ref);
        ssimVal = [ssimVal, currssimVal];
    end
    
%     figure()
%     plot(1:(c-1), ssimVal);
    
    [minVal, minIdx] = min(ssimVal);
    dataTable.minssimVal(ii) = minVal;
    
    if(minVal < thresh)
        dataTable.isCut(ii) = 1;
        if (minIdx < ceil(len/2))
            dataTable.FirstFrame(ii) = minIdx + 1;
            dataTable.GTFrameNum(ii) = ceil(len/2) - minIdx;
        end
    end
end

end

