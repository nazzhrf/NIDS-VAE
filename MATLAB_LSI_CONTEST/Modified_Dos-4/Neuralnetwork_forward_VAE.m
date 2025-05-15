% OX (Circle or Cross) Judgement Program (Variational Auto Encoder) 
% LSI Design Contest 2025
%
% Neuralnetwork_forward_VAE function
%  Forward process 
%
% Input:
%           X : Input data
%           w2_mean : Weight (Input Layer to Hidden Layer (Mean): Encoder)
%           w2_var : Weight (Input Layer to Hidden Layer (Variance): Encoder)
%           w3 : Weight (Hidden Layer to Output Layer: Decoder)
%           b2_mean : Bias (Hidden Layer, Mean)
%           b2_var : Bias (Hidden Layer, Variance)
%           b3 : Bias (Output Layer)
%   
% Output: 
%           z2_mean : Hidden Layer 
%           z2_var : Hidden Layer 
%           a2_mean : Hidden Layer (öİ•Ï”: latent variable)
%           a2_var : Hidden Layer (öİ•Ï”: latent variable)
%           a2 : öİ•Ï”: latent variable
%           z3 : Output Layer  
%           a3 : Output Layer
%
% Requrired : OX_judge_VAE.m, Neuralnetwork_VAE.m, Neuralnetwork_forward_VAE.m
%
% see also OX_judge_VAE, Neuralnetwork_VAE, Neuralnetwork_forward_VAE.
%
function [z2_mean,z2_var, a2_mean, a2_var,a2,z3,a3] = Neuralnetwork_forward_VAE(X,w2_mean,w2_var,w3,b2_mean,b2_var,b3)

z2_mean = w2_mean * X + b2_mean;        % Input weight for hidden layer
z2_var = w2_var * X + b2_var;           % Input weight for hidden layer

a2_mean = z2_mean;
a2_var = log(1+exp(z2_var));            % Softplus

eps = randn(size(z2_mean));
a2 = a2_mean + sqrt(a2_var).*eps;

z3 = w3 * a2 + b3;                      % Input weight for hidden layer
a3= 1./(1+exp(-z3));                    % Output for hidden layer

end
