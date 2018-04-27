%% Gilad 17.11.17
% trying to extract the videos for training:
clear; clc;
%% reading csv file into trainTable:
csvID = fopen('ava_train_v1.0.csv');
avaTrain = textscan(csvID,'%s %f %f %f %f %f %f', 'Delimiter', ',');
fclose(csvID);
trainTable = table(avaTrain{1}, avaTrain{2}, avaTrain{3}, avaTrain{4}, ...
    avaTrain{5}, avaTrain{6}, avaTrain{7}, ...
    'VariableName', {'videoID', 'middleFrameTimeStamp', 'topLeft_x',...
    'topLeft_y', 'bottomRight_x', 'bottomRight_y', 'actionLabel'});
%% getting to youTube urls's:
len = length(trainTable.videoID);
yT_url = 'https://www.youtube.com/embed/';
urlCell = cell(len,1);
for ii = 1 : len
    t_url  = ['?start=', num2str(trainTable.middleFrameTimeStamp(ii)-2), ...
          '&end=', num2str(trainTable.middleFrameTimeStamp(ii)+2)];
    urlCell{ii} = [yT_url, trainTable.videoID{ii}, t_url];
end
cleanUrl = unique(urlCell);
vidIDs = unique(trainTable.videoID);
%% writing into text:
fileID = fopen('urls.txt', 'w');
 for ii = 1:length(cleanUrl)
     fprintf(fileID, '%s\r\n', cleanUrl{ii});
 end
 fclose(fileID);
%%
% yT_url = 'https://www.youtube.com/embed/';
% t_url  = ['?start=', num2str(trainTable.middleFrameTimeStamp(ii)-2), ...
%           '&end=', num2str(trainTable.middleFrameTimeStamp(ii)+2)];
% urlCell = [yT_url, trainTable.videoID{ii}, t_url];
% web(urlStr);
% % transmit_vid('urlStr')
% %% videoFileReader:
% VFR = vision.VideoFileReader(urlStr);
% VP = vision.VideoPlayer;
% writeVid = vision.VideoFileWriter('fromurl.mp4', 'FileFormat', 'MPEG4');
% n = 1;
% while ~isDone(VFR)
%     currFrame = step(VFR);
% %     swingingLight(:,:,n) = rgb2gray(currFrame);
%     step(writeVid, rgb2gray(currFrame));
%     step(VP, currFrame);
%     n = n+1;
% end
% release(VP);
% release(VFR);
% release(writeVid);