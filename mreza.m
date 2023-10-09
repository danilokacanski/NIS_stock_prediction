% Solve an Input-Output Fitting problem with a Neural Network

% This script assumes these variables are defined:
%
%   inputs - input data.
%   target - target data.

x = inputs;
t = target;

trainFcn = 'trainlm';  % Bayesian Regularization backpropagation.

% Create a Fitting Network
hiddenLayerSize = [10,8];
net = feedforwardnet(hiddenLayerSize,trainFcn);

net.performParam.regularization = 0.01;
net.trainParam.max_fail = 50;
% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 75/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Activation functions %
net.layers{1}.transferFcn = 'tansig';
net.layers{2}.transferFcn = 'elliotsig';
net.layers{3}.transferFcn = 'elliotsig';

% Set the maximum number of epochs
net.trainParam.epochs = 1200;

% Set the maximum Mu value
net.trainParam.mu_max = 1e15;

% Train the Network
[net,tr] = train(net,x,t);

% Test the Network
y = net(x);
e = gsubtract(t,y);
RMSE = sqrt(perform(net,t,y))
MAE = mae(gsubtract(t,y))

% View the Network
view(net)

% Predicted max and min for the next 5 days from the last day in the data
prediction = net(predict_value);
fprintf('Predvidjena maksimalna i minimalna cena za sledecih 5 dana je: Max = %f, Min = %f\n', prediction(1), prediction(2));
