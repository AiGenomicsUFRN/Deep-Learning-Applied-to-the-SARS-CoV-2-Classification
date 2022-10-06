
clear

load('TrainData.mat');

TrainSize = size(treinamento,1);

LabelTrain = categorical([ones(1,480),2*ones(1,480)]);


TrainMap = ['ACGTN']; %One-hot enconding

vK=1:TrainSize;


for i=1:TrainSize
    treinamento.Length(i) = size(treinamento.Sequence{i},2);
end
maxLength = max(treinamento.Length);

TrainSeqOneHotEnc = zeros(maxLength,1,length(TrainMap),length(vK));

tic
for i=1:length(vK)
    TempString = treinamento.Sequence(vK(i));
    if (length(vK(i)) < maxLength)
        Temp = [ TempString{1} char('X'*ones(1,maxLength-length(TempString{1})))];
    else
        Temp = [ TempString{1}];
    end       
%     disp(length(Temp))
    TrainSeqOneHotEnc(:,:,:,i) = OneHotEncoding3D(Temp ,TrainMap);
end
toc

kfold = 5;
indices = crossvalind('Kfold',LabelTrain,kfold);
test = (indices == 1); % which points are in the test set
train = ~test;
vectorTraining = TrainSeqOneHotEnc(:,:,:,train);


inputSize = [maxLength 1 5];
numClasses = 2;

%%
layer0 = imageInputLayer(inputSize,'Normalization','rescale-zero-one','Name','GenomeImage');
layer0 = imageInputLayer(inputSize,'Mean', mean(vectorTraining,4),'Name', 'Input1');

layer1 = convolution2dLayer([256 1],8,'stride',1,'Name', 'Conv1');
layer2 = batchNormalizationLayer('Name','BatchNorm1');
layer3 = reluLayer('Name','ReLu1');
layer4 = maxPooling2dLayer([8 1],'stride',[2 1],'Name', 'MaxPooling1');

layer5 = convolution2dLayer([64 1],16,'stride',1,'Name', 'Conv2');
layer6 = batchNormalizationLayer('Name','BatchNorm2');
layer7 = reluLayer('Name','ReLu2');
layer8 = maxPooling2dLayer([16 1],'stride',[2 1],'Name', 'MaxPooling2');

layer9 = convolution2dLayer([32 1],32,'stride',1,'Name', 'Conv3');
layer10 = batchNormalizationLayer('Name','BatchNorm3');
layer11 = reluLayer('Name','ReLu3');
layer12 = maxPooling2dLayer([32 1],'stride',[2 1],'Name', 'MaxPooling3');

layer13= convolution2dLayer([32 1],64,'stride',1,'Name', 'Conv4');
layer14 = batchNormalizationLayer('Name','BatchNorm4');
layer15 = reluLayer('Name','ReLu4');
layer16 = maxPooling2dLayer([64 1],'stride',[2 1],'Name', 'MaxPooling4');

layer17 = fullyConnectedLayer(64, 'Name', 'FC1');
layer18 = dropoutLayer(0.4,'Name','Drop1');
%layer19 = reluLayer('Name','ReLu5'); %layer18a = batchNormalizationLayer('Name','BatchNorm5');

layer20 = fullyConnectedLayer(32, 'Name', 'FC2');
layer21 = dropoutLayer(0.4,'Name','Drop2');
%layer22 = reluLayer('Name','ReLu6'); %batchNormalizationLayer('Name','BatchNorm6');

layer23 = fullyConnectedLayer(16, 'Name', 'FC3');
layer24 = dropoutLayer(0.4,'Name','Drop3');
%layer25 = reluLayer('Name','ReLu7'); %batchNormalizationLayer('Name','BatchNorm7');

layer26 = fullyConnectedLayer(numClasses,'Name','FC4');
layer27 =  softmaxLayer('Name','SoftMax1');
layer28 = classificationLayer('Name','Classification1');


layers = [layer0 ...
              layer1 layer2 layer3 layer4 ...
              layer5 layer6 layer7 layer8 ...
              layer9 layer10 layer11 layer12 ...
              layer13 layer14 layer15 layer16 ...
              layer17 layer18    ...
              layer20 layer21   ...
              layer23 layer24   ...
              layer26 layer27, layer28];
          

infoV = cell(kfold, 1);
netV = cell(kfold, 1);

tempFinal=zeros(1,5);
for i=1:kfold
    disp(i)
    test = (indices == i) ; % which points are in the test set
    train = ~test;
    vectorTraining = TrainSeqOneHotEnc(:,:,:,train);
    vectorTrainingLabel = LabelTrain(train);

    vectorValidation = TrainSeqOneHotEnc(:,:,:,test);
    vectorValidationLabel = LabelTrain(test);
  
    % 'Plots','training-progress',...
    
    options = trainingOptions('adam', ...
    'MiniBatchSize',128,...
    'MaxEpochs',12, ...
    'ValidationData',{vectorValidation vectorValidationLabel}, ...
    'ValidationFrequency',8, ...
    'Verbose',false, ...
    'InitialLearnRate',0.001, ...
    'Shuffle','every-epoch');
   tic
   [net,info] = trainNetwork(vectorTraining,vectorTrainingLabel,layers,options);
   tempFinal(i) = toc;
   infoV{i} = info;
   netV{i} = net;
end
