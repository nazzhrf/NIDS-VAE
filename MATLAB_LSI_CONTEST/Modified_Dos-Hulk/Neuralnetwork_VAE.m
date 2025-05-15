% OX (Circle or Cross) Judgement Program (Variational Auto Encoder) 
% LSI Design Contest 2025
%
% NNeuralnetwork_VAE function
%  Learing process (backpropagation)
%
% Input:
%           X : Input data
%           t : Label
%           w2 : Initial weight (Input Layer to Hidden Layer: Encoder)
%           w3 : Initial weight (Hidden Layer to Output Layer: Decoder)
%           b2 : Initial bias (Hidden Layer)
%           b3 : Initial bias (Output Layer)
%           eta : Step size
%           epoch : The number of epochs
%           L2func : Activation function in Layer2 ('Sigmoid' or 'ReLUfnc')
%           L3func : Activation function in Layer3 ('Sigmoid_MSE' or 'Sigmoid_BCE' )
%
% Output:
%           w2 : Final weights (Input Layer to Hidden Layer: Encoder)
%           w3 : Final weights (Hidden Layer to Output Layer: Decoder)
%           b2 : Final bias (Hidden Layer)
%           b3 : Final bias (Output Layer)
%           w2_t : History of weights
%           w3_t : History of weights
%           b2_t : History of bias
%           b3_t : History of bias
%           E : Losss history
%
% Requrired : OX_judge_VAE.m, Neuralnetwork_VAE.m, Neuralnetwork_forward_VAE.m
%
% see also OX_judge_VAE, Neuralnetwork_VAE, Neuralnetwork_forward_VAE.
%
function [w2_mean,w2_var,w3,b2_mean,b2_var,b3,w2_mean_t,w2_var_t,w3_t,b2_mean_t,b2_var_t,b3_t,E] = Neuralnetwork_VAE(X,t,w2_mean,w2_var,w3,b2_mean,b2_var,b3,eta,epoch,L2func,L3func)

    w2_mean_t = zeros(size(w2_mean,1),size(w2_mean,2),epoch);
    w2_var_t = zeros(size(w2_var,1),size(w2_var,2),epoch);
    w3_t = zeros(size(w3,1),size(w3,2),epoch);
    b2_mean_t = zeros(size(b2_mean,1), size(b2_mean,2),epoch);
    b2_var_t = zeros(size(b2_var,1), size(b2_var,2),epoch);
    b3_t = zeros(size(b3,1), size(b3,2),epoch);

    E = zeros(1,epoch);                             % Array for storing errors

    %% Forwardpropagation & Backpropagation
    for j = 1 : epoch

        z2_mean = w2_mean * X + b2_mean;            % Input weight for hidden layer
        z2_var = w2_var * X + b2_var;               % Input weight for hidden layer
        
        a2_mean = z2_mean;
        a2_var = log(1 + exp(z2_var));              % Softplus
        
        eps = randn(size(z2_mean));
        a2 = a2_mean + sqrt(a2_var).*eps;

        z3 = w3 * a2 + b3;                          % z3: Weighted sum of hidden layers
        a3 = 1./(1+exp(-z3));                       % a3: Output for output layerÅiActivation function: SigmoidÅj

        Erec = -t.*log(a3) - (1-t).*log(1-a3);      % Cross entropy error
        Ereg = -1/2 *(1 + log(a2_var) - a2_mean.^2 - a2_var);

        e = sum(sum(Erec),2) + sum(sum(Ereg),2);    % Sum of errors for all data
        E(1,j) = e/size(X,2);                       % Stores error per piece of data

        dEda3 = -t./a3 + (1-t)./(1-a3);
        dEdz3 = dEda3 .* a3 .* (1-a3);
        delta3 = dEdz3;

        % Backpropagation
        dEdb3 = sum(delta3,2);
        dEdw3 = (a2 * (delta3).').';

        dEda2_mean =  w3.' * (delta3)+a2_mean;
        dEda2_var =  (w3.' * (delta3)).*eps./(2*sqrt(a2_var)) + 0.5*(1-1./a2_var);

        dEdz2_mean = dEda2_mean;
        dEdz2_var = 1./(1+exp(-z2_var));            % Differentiation of Softplus (= Sigmoid)

        delta2_mean = dEdz2_mean;
        delta2_var = dEdz2_var;

        dEdb2_mean = sum(delta2_mean,2);
        dEdw2_mean = (X * delta2_mean.').';
        dEdb2_var = sum(delta2_var,2);
        dEdw2_var = (X * delta2_var.').';

        % Parameter Update
        b3 = b3 - eta * dEdb3;
        w3 = w3 - eta * dEdw3;

        b2_mean = b2_mean - eta * dEdb2_mean;
        w2_mean = w2_mean - eta * dEdw2_mean;
        b2_var = b2_var - eta * dEdb2_var;
        w2_var = w2_var - eta * dEdw2_var;

        w2_mean_t(:,:,j) = w2_mean;                 % w2_t = zeros(size(w2,1),size(w2,2),epoch);
        w2_var_t(:,:,j) = w2_var;
        w3_t(:,:,j) = w3;
        b2_mean_t(:,:,j) = b2_mean;                 % b2_t = zeros(size(b2,1),size(b2,2),epoch);
        b2_var_t(:,:,j) = b2_var;
        b3_t(:,:,j) = b3;
    end
end



