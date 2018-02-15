function [trainTable,testTable, imgPerm] = train_test(FrameData, existTable, trainPercent, testPercent)
% divides into train and test sets. Also shows some images from the test,
% with the boxes in them to see that it came out well.
%% Check that train and test don't overlap:
if trainPercent + testPercent > 1
    error('Overlap of train and test!');
end
%% divide into train and test:
dataLength = length(existTable.names);
dataPerm = randperm(dataLength);
trainTable = existTable(dataPerm(1 : round(trainPercent*dataLength)),:); % the first trainPercent images in the permutation
testTable  = existTable(dataPerm(round((1-testPercent)*dataLength) + 1 : end),:); % the last testPercent images in the perm
% go to frame directoy:
frameDir = getFrameDir();
cd(frameDir);
% figures:
figure(1); hold on;
imgPerm = randperm(length(testTable.names),20);
for kk = 1:20
    subplot(4,5,kk);
    imshow(FrameData.ReadFcn(testTable.names{imgPerm(kk)}));
end
hold off;

figure(2); hold on;
for kk = 1:20
    img = FrameData.ReadFcn(testTable.names{imgPerm(kk)});
    pos = [testTable.sit{imgPerm(kk)}; testTable.stand{imgPerm(kk)}; testTable.walk{imgPerm(kk)}];
    actStr = [''];
    img = insertObjectAnnotation(img, 'rectangle', pos, actStr,...
                'Color', {'cyan'}, 'FontSize', 12, 'Linewidth', 2);
    subplot(4,5,kk);
    imshow(img);
end
hold off;
end

