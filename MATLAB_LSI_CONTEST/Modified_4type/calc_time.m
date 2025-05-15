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
Layer1 = 9;                     
Layer2 = 1;    
Layer3 = Layer1;                 

L2func = 'Softplus';            
L3func = 'Sigmoid_BCE';         

w2 = rand(Layer2,Layer1);       
w3 = rand(Layer3,Layer2);       

b2 = (-0.5)*ones(Layer2,1);
b3 = (-0.5)*ones(Layer3,1);

% Ukuran sampel yang ingin diuji
sample_sizes = [1, 10, 100, 500, 1000, 2000, 4000];
execution_times = zeros(size(sample_sizes));

% Mengukur waktu eksekusi forward pass untuk berbagai ukuran sampel
fprintf('Execution Time Measurements (in ms):\n');
for i = 1:length(sample_sizes)
    num_samples = sample_sizes(i);
    X_subset = TestData(1:num_samples, :)';  % Ambil subset dari test data

    tic;  % Mulai stopwatch
    [z2,a2,z3,a3] = Neuralnetwork_forward_AE(X_subset, w2, w3, b2, b3, L2func, L3func);
    execution_times(i) = toc * 1000;  % Simpan waktu eksekusi dalam ms

    fprintf('Processing first %d rows: %.3f ms\n', num_samples, execution_times(i));
end
