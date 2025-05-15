clear;
close all;
clc;

rng(2025);        % Set random seed.

% Load test data from CSV files
B_data = readmatrix("D:\\TKTE_PTE\\VAE_Dataset\\4core\\train_benign.csv");
D_data = readmatrix("D:\\TKTE_PTE\\VAE_Dataset\\4core\\train_botnet.csv");
H_data = readmatrix("D:\\TKTE_PTE\\VAE_Dataset\\4core\\train_ddos.csv");

% Remove header row
B_data = B_data(2:end, :);
D_data = D_data(2:end, :);
H_data = H_data(2:end, :);

% Select first 500 rows (or available rows if less than 500)
B_data = B_data(1:min(500, size(B_data,1)), :)';
D_data = D_data(1:min(500, size(D_data,1)), :)';
H_data = H_data(1:min(500, size(H_data,1)), :)';

% Teacher data untuk rekonstruksi
LabelData(:,1:500) = 0;    % Benign
LabelData(:,501:1000) = 0.75; % DoS
LabelData(:,1001:1500) = 1; % Heartbleed

% Test data
TestData = [B_data D_data H_data];
TLabelData = LabelData;

% Parameter setting
Layer1 = 9;                     % Number of input layer units
Layer2 = 2;                     % Number of hidden layer units
Layer3 = Layer1;                % Number of output layer units

L2func = 'ReLUfnc';             % Hidden layer activation ('Sigmoid' or 'ReLUfnc')
L3func = 'Sigmoid_BCE';         % Output layer activation ('Sigmoid_MSE' or 'Sigmoid_BCE')

% Initialization of weights and biases
w2_mean = rand(Layer2,Layer1);
w2_var = rand(Layer2,Layer1);
w3 = rand(Layer3,Layer2);

b2_mean = (-0.5)*ones(Layer2,1);
b2_var = (-0.5)*ones(Layer2,1);
b3 = (-0.5)*ones(Layer3,1);

% Learning rate
eta = 0.0001;
epoch = 100000;

% Pre-learning Test
X = TestData;
[z2_mean,z2_var, a2_mean, a2_var,a2,z3,a3] = Neuralnetwork_forward_VAE(X,w2_mean,w2_var,w3,b2_mean,b2_var,b3);

% Training VAE
[w2_mean,w2_var,w3,b2_mean,b2_var,b3,~,~,~,~,~,~,E] = Neuralnetwork_VAE(X,TLabelData,w2_mean,w2_var,w3,b2_mean,b2_var,b3,eta,epoch,L2func,L3func);

% Post-learning Test
[z2_mean,z2_var, a2_mean, a2_var,a2,z3,a3] = Neuralnetwork_forward_VAE(X,w2_mean,w2_var,w3,b2_mean,b2_var,b3);

% Threshold untuk klasifikasi
[~, predicted_labels] = max(a3, [], 1);
true_labels = TLabelData(1,:);

% TP, FP, TN, FN
TP = sum((predicted_labels == true_labels) & (true_labels ~= 0));
FP = sum((predicted_labels ~= true_labels) & (true_labels == 0));
TN = sum((predicted_labels == true_labels) & (true_labels == 0));
FN = sum((predicted_labels ~= true_labels) & (true_labels ~= 0));

% Accuracy
accuracy = (TP + TN) / (TP + TN + FP + FN);

% Precision
precision = TP / (TP + FP);

% Recall (Sensitivity)
recall = TP / (TP + FN);

% F1-Score
f1_score = 2 * (precision * recall) / (precision + recall);

% AUC-ROC
score_values = max(a3, [], 1)';
[X_ROC, Y_ROC, ~, AUC] = perfcurve(true_labels, score_values, 1);

% Visualization
figure(1);
hold on;
plot(a2(1,1:500), a2(2,1:500), 'or'); % B samples
plot(a2(1,501:1000), a2(2,501:1000), 'xk'); % D samples
plot(a2(1,1001:1500), a2(2,1001:1500), '^b'); % H samples
hold off;
xlabel('y_1 = a^2_1'); ylabel('y_2 = a^2_2');
title('Latent Variable (Final weights and bias)');
box('on');

figure(2);
plot(E);
xlabel('Epoch'); ylabel('Error');

fprintf('Accuracy: %.4f\n', accuracy);
fprintf('Precision: %.4f\n', precision);
fprintf('Recall (Sensitivity): %.4f\n', recall);
fprintf('F1-Score: %.4f\n', f1_score);
fprintf('AUC: %.4f\n', AUC);

% Plot ROC Curve
figure;
plot(X_ROC, Y_ROC, 'b-', 'LineWidth', 2);
xlabel('False Positive Rate');
ylabel('True Positive Rate');
title('ROC Curve');
grid on;
