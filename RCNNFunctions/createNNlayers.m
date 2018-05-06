function [layers] = createNNlayers(labels)
% Create Network that we'll use train, from get set, and change so that the
% output is correct.
%% Choose Network Architecture
choice = questdlgtimeout(60,'Which net do you want to use?',...
    	'Transfer Network', 'alexnet', 'vgg16', 'vgg19', 'alexnet');
switch choice
    case 'alexnet'
        alex = alexnet; 
        layers = alex.Layers
    case 'vgg16'
        warndlg('Note that vgg16 needs a lot of GPU RAM!', 'vgg16');
        vgg  = vgg16;
        layers = vgg.Layers
    case 'vgg19'
        vgg  = vgg19;
        layers = vgg.Layers
    case 'resnet50'
        res = resnet50;
        layers = res.Layers
end
%% Modify Pre-trained Network 
% AlexNet and vgg16 were trained to recognize 1000 classes, we need to modify them to
% recognize n classes.
layers(end - 2) = fullyConnectedLayer(length(labels) + 1); % change this based on # of classes + background
layers(end) = classificationLayer()
end

