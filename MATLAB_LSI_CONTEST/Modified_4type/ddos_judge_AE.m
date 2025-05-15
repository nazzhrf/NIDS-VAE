clear;
close all;

% Load test data from CSV files
ddos_data = readmatrix("C:\\EL\\TKTE_PTE\\VAE_Dataset\\4type\\a3_ddos.csv");

% Teacher data untuk rekonstruksi
LabelData(:,1:2000) = 0;  % Semua elemen Benign menjadi 0
LabelData(:,2001:4000) = 1; % Semua elemen Not Benign menjadi 1

% Test data
TestData = ddos_data;
TLabelData = LabelData;

% Parameter setting
Layer1 = 9;                     % Number of input layer units
Layer2 = 1;    
Layer3 = Layer1;                 % Number of hidden layer units           

L2func = 'Softplus';             % Algorithm of hidden layer ('Sigmoid' or Default: 'ReLUfnc')
L3func = 'Sigmoid_BCE';         % Algorithm of output layer and error ('Sigmoid_MSE' or Default : 'Sigmoid_BCE' (Binary Cross Entropy))
         
w2 = rand(Layer2,Layer1);       % Hidden layer's weight matrix for supervisor data
w3 = rand(Layer3,Layer2);       % Hidden layer's weight matrix for supervisor data

b2 = (-0.5)*ones(Layer2,1);
b3 = (-0.5)*ones(Layer3,1);

% 学習率
% Learning rate
eta = 0.0001;	%学習率が高すぎると更新した係数が大きくなりすぎてコストが減らなくなる	
				%If the learning rate is too high, the updated coefficient becomes too large and the cost may not decrease

epoch = 100000;

% Pre-learning Test
X = TestData';
[z2,a2,z3,a3] = Neuralnetwork_forward_AE(X,w2,w3,b2,b3,L2func,L3func);

% AE Learning
t = LabelData;
% [w2,w3,b2,b3,w2_t,w3_t,b2_t,b3_t,E] = Neuralnetwork_AE(X,t,w2,w3,b2,b3,eta,epoch,L2func,L3func);

% Inisialisasi error
E = zeros(1, epoch);

% Loop pembelajaran AE dengan print error setiap 10 epoch
for i = 1:epoch
    [w2,w3,b2,b3,w2_t,w3_t,b2_t,b3_t,E(i)] = Neuralnetwork_AE(X,t,w2,w3,b2,b3,eta,1,L2func,L3func);
    
    % Cetak error jika i adalah pangkat 10
    if any(i == 10.^[1:log10(epoch)])  
        fprintf('Epoch %d: Error = %.6f\n', i, E(i));
    end
end

% Post-learning Test
[z2,a2,z3,a3] = Neuralnetwork_forward_AE(X,w2,w3,b2,b3,L2func,L3func);

fprintf('w2\n');   disp(w2);
fprintf('b2\n');   disp(b2);
fprintf('w3\n');        disp(w3);
fprintf('b3\n');        disp(b3);

fprintf('Performance Metrics\n');
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
plot(a2(1,1:2000), zeros(1,2000), 'or'); % B samples
plot(a2(1,2001:4000), zeros(1,2000), 'xk'); % NB samples
hold off;
xlabel('y_1 = a^2_1');
ylabel('Zero Baseline');
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
% fprintf('a2\n');        disp(a2);
% fprintf('z3\n');        disp(z3);
% fprintf('a3\n');        disp(a3);

% a2_ae_out = "C:\\EL\\TKTE_PTE\\VAE_Dataset\\4type\\a2_ae_dos.csv" ;
% 
% % Transpose a3 untuk menyimpan kolom sebagai baris
% a2_transposed = a2';
% 
% % Alternatif dengan writematrix (lebih modern, MATLAB R2019a ke atas)
% writematrix(a2_transposed, a2_ae_out);
%% KONVERSI WEIGHT DAN BIAS DALAM DESIMLA KE FIXED POINT Q.5.10

% Parameter format Q5.10
a = 5; % Integer bits
b = 10; % Fraction bits

% Konversi semua matriks ke heksadesimal Q5.10
w2_hex = arrayfun(@(x) dec2q(x, a, b), w2, 'UniformOutput', false);
b2_hex = arrayfun(@(x) dec2q(x, a, b), b2, 'UniformOutput', false);
w3_hex = arrayfun(@(x) dec2q(x, a, b), w3, 'UniformOutput', false);
b3_hex = arrayfun(@(x) dec2q(x, a, b), b3, 'UniformOutput', false);

% Menampilkan hasil konversi
disp('w2(Hex):');
disp(w2_hex);
disp('b2 (Hex):');
disp(b2_hex);
disp('w3 (Hex):');
disp(w3_hex);
disp('b3 (Hex):');
disp(b3_hex);
%% % MENYIMPAN WEIGHT DAN BIAS KE FILE TXT

file_path = "C:\\EL\\VLSI\\VAE_NEW_ISICAS_20-03-2025\\MATLAB_LSI_CONTEST\\Modified_4type\\wb_training\\ae_wb_ddos.txt";

% Buka file untuk menulis (mode 'w' akan membuat file jika belum ada)
fileID = fopen(file_path, 'w');

% Pastikan file berhasil dibuka
if fileID == -1
    error('Gagal membuka file untuk menulis.');
end

% Tulis w2 ke file (baris 1-9)
fprintf(fileID, "%s\n", w2_hex{:});

% Tulis b2 ke file (baris 10)
fprintf(fileID, "%s\n", b2_hex{:});

% Tulis w3 ke file (baris 11-19)
fprintf(fileID, "%s\n", w3_hex{:});

% Tulis b3 ke file (baris 20-27)
fprintf(fileID, "%s\n", b3_hex{:});

% Tutup file
fclose(fileID);

disp(['File telah disimpan di: ', file_path]);