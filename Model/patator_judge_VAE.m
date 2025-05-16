clear;
close all;
clc;

rng(2025);        % Set random seed.

% Load test data from CSV files
b_data = readmatrix("C:\\EL\\TKTE_PTE\\VAE_Dataset\\4type\\train_benign_for_patator.csv");
patator_data = readmatrix("C:\\EL\\TKTE_PTE\\VAE_Dataset\\4type\\train_patator.csv");

% Remove header row
b_data = b_data(2:end, :);
patator_data = patator_data(2:end, :);

% Select first 500 rows
b_data = b_data(1:1000, :)'; % Transpose to match expected format
patator_data = patator_data(1:1000, :)';

% Teacher data untuk rekonstruksi
LabelData(:,1:1000) = 0;  % Semua elemen Benign menjadi 0
LabelData(:,1001:2000) = 1; % Semua elemen Not Benign menjadi 1

% Test data
TestData = [b_data patator_data];
TLabelData = LabelData;

% Parameter setting
Layer1 = 9;                     % Number of input layer units
Layer2 = 2;                     % Number of hidden layer units
Layer3 = Layer1;                % Number of output layer units

L2func = 'ReLUfnc';             % Algorithm of hidden layer ('Sigmoid' or Default: 'ReLUfnc')
L3func = 'Sigmoid_BCE';         % Algorithm of output layer and error ('Sigmoid_MSE' or Default : 'Sigmoid_BCE' (Binary Cross Entropy))

% Initialization of weights and biases
w2_mean = rand(Layer2,Layer1);
w2_var = rand(Layer2,Layer1);
w3 = rand(Layer3,Layer2);

b2_mean = (-0.5)*ones(Layer2,1);
b2_var = (-0.5)*ones(Layer2,1);
b3 = (-0.5)*ones(Layer3,1);

% Learning rate
eta = 0.00001;
epoch = 100000;

% Pre-learning Test
X = TestData;
[z2_mean,z2_var, a2_mean, a2_var,a2,z3,a3] = Neuralnetwork_forward_VAE(X,w2_mean,w2_var,w3,b2_mean,b2_var,b3);

% Training VAE
[w2_mean,w2_var,w3,b2_mean,b2_var,b3,~,~,~,~,~,~,E] = Neuralnetwork_VAE(X,TLabelData,w2_mean,w2_var,w3,b2_mean,b2_var,b3,eta,epoch,L2func,L3func);

% Post-learning Test
[z2_mean,z2_var, a2_mean, a2_var,a2,z3,a3] = Neuralnetwork_forward_VAE(X,w2_mean,w2_var,w3,b2_mean,b2_var,b3);

fprintf('Final Weight\n');

fprintf('w2_mean\n');   disp(w2_mean);
fprintf('b2_mean\n');   disp(b2_mean);
fprintf('w2_var\n');    disp(w2_var);
fprintf('b2_var\n');    disp(b2_var);
fprintf('w3\n');        disp(w3);
fprintf('b3\n');        disp(b3);

% Threshold untuk klasifikasi
threshold = 0.5;
predicted_labels = a3(1,:) > threshold; % Ambil nilai dari neuron pertama

% Ground truth
true_labels = TLabelData(1,:) > threshold; % Sesuaikan dengan dimensi prediksi

% Ubah ke format vektor kolom
true_labels = true_labels(:);
predicted_labels = predicted_labels(:);

% TP, FP, TN, FN
TP = sum((predicted_labels == 1) & (true_labels == 1));
FP = sum((predicted_labels == 1) & (true_labels == 0));
TN = sum((predicted_labels == 0) & (true_labels == 0));
FN = sum((predicted_labels == 0) & (true_labels == 1));

% Accuracy
accuracy = (TP + TN) / (TP + TN + FP + FN);

% Precision
precision = TP / (TP + FP);

% Recall (Sensitivity)
recall = TP / (TP + FN);

% F1-Score
f1_score = 2 * (precision * recall) / (precision + recall);

% AUC-ROC menggunakan MATLAB perfcurve
score_values = a3(1,:)'; % Ambil probabilitas dari neuron pertama
[X_ROC, Y_ROC, ~, AUC] = perfcurve(true_labels, score_values, 1);


% Visualization
figure(1);
hold on;
plot(a2(1,1:1000), a2(2,1:1000), 'or'); % B samples
plot(a2(1,1001:2000), a2(2,1001:2000), 'xk'); % NB samples
hold off;
xlabel('y_1 = a^2_1'); ylabel('y_2 = a^2_2');
title('Latent Variable (Final weights and bias)');
box('on');

figure(2);
plot(E);
xlabel('Epoch'); ylabel('Error');

% Menampilkan hasil
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

% fprintf('Final Latent Variable\n');
% fprintf('Test data X\n');   disp(X);
% fprintf('z2_mean\n');   disp(z2_mean);
% fprintf('z2_var\n');    disp(z2_var);
% fprintf('a2_mean\n');   disp(a2_mean);
% fprintf('a2_var\n');    disp(a2_var);
fprintf('a2\n');        disp(a2);
% fprintf('z3\n');        disp(z3);
fprintf('a3\n');        disp(a3);

a3_out = "C:\\EL\\TKTE_PTE\\VAE_Dataset\\4type\\a3_patator.csv" ;

% Transpose a3 untuk menyimpan kolom sebagai baris
a3_transposed = a3';

% Alternatif dengan writematrix (lebih modern, MATLAB R2019a ke atas)
writematrix(a3_transposed, a3_out);

%% KONVERSI WEIGHT DAN BIAS DALAM DESIMLA KE FIXED POINT Q.5.10

% Parameter format Q5.10
a = 5; % Integer bits
b = 10; % Fraction bits

% Konversi semua matriks ke heksadesimal Q5.10
w2_mean_hex = arrayfun(@(x) dec2q(x, a, b), w2_mean, 'UniformOutput', false);
b2_mean_hex = arrayfun(@(x) dec2q(x, a, b), b2_mean, 'UniformOutput', false);
w2_var_hex  = arrayfun(@(x) dec2q(x, a, b), w2_var, 'UniformOutput', false);
b2_var_hex  = arrayfun(@(x) dec2q(x, a, b), b2_var, 'UniformOutput', false);
w3_hex      = arrayfun(@(x) dec2q(x, a, b), w3, 'UniformOutput', false);
b3_hex      = arrayfun(@(x) dec2q(x, a, b), b3, 'UniformOutput', false);

% Menampilkan hasil konversi
disp('w2_mean (Hex):');
disp(w2_mean_hex);
disp('b2_mean (Hex):');
disp(b2_mean_hex);
disp('w2_var (Hex):');
disp(w2_var_hex);
disp('b2_var (Hex):');
disp(b2_var_hex);
disp('w3 (Hex):');
disp(w3_hex);
disp('b3 (Hex):');
disp(b3_hex);
%% % MENYIMPAN WEIGHT DAN BIAS KE FILE TXT
input_buffer = strings(1, 27); 

% Mengisi input_buffer sesuai format yang diminta
for i = 1:9
    if i == 1
        input_buffer(i) = strcat(w2_mean_hex{1, i}, w2_mean_hex{2, i}, b2_mean_hex{1}, b2_mean_hex{2});
    else
        input_buffer(i) = strcat(w2_mean_hex{1, i}, w2_mean_hex{2, i}, '0000', '0000');
    end
end

for i = 10:18
    idx = i - 9;
    if i == 10
        input_buffer(i) = strcat(w2_var_hex{1, idx}, w2_var_hex{2, idx}, b2_var_hex{1}, b2_var_hex{2});
    else
        input_buffer(i) = strcat(w2_var_hex{1, idx}, w2_var_hex{2, idx}, '0000', '0000');
    end
end

for i = 19:27
    idx = i - 18;
    input_buffer(i) = strcat(w3_hex{idx, 1}, w3_hex{idx, 2}, b3_hex{idx}, '0000');
end

% Menampilkan hasil
disp('input_buffer (Hex 64-bit):');
disp(input_buffer);

% Menyimpan ke file teks
file_path = "C:\\EL\\VLSI\\VAE_NEW_ISICAS_20-03-2025\\MATLAB_LSI_CONTEST\\Modified_4type\\wb_training\\input_buffer_patator.txt";
fid = fopen(file_path, 'w');
if fid == -1
    error('Gagal membuka file untuk penulisan.');
end

for i = 1:length(input_buffer)
    fprintf(fid, "%s\n", input_buffer(i));
end

fclose(fid);

disp(['File telah disimpan di: ', file_path]);
