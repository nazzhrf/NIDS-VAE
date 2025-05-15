% OX (Circle or Cross) Judgement Program (Auto Encoder) 
% LSI Design Contest 2025
%
% Neuralnetwork_forward_AE function
%  Forward process 
%
% Input:
%           X : Input data
%           w2 : Weight (Input Layer to Hidden Layer: Encoder)
%           w3 : Weight (Hidden Layer to Output Layer: Decoder)
%           b2 : Bias (Hidden Layer)
%           b3 : Bias (Output Layer)
%           L2func : Activation Function in Layer2 ('Sigmoid' or 'ReLUfnc')
%           L3func : Activation Function in Layer3 ('Sigmoid_MSE' or 'Sigmoid_BCE' )
%   
% Output: 
%           z2 : Hidden Layer 
%           a2 : Hidden Layer (öÝ•Ï”: latent variable)
%           z3 : Output Layer  
%           a3 : Output Layer
%
% Requrired : OX_judge_AE.m, Neuralnetwork_AE.m, Neuralnetwork_forward_AE.m
%
% see also OX_judge_AE, Neuralnetwork_AE, Neuralnetwork_forward_AE.
%
function [z2,a2,z3,a3] = Neuralnetwork_forward_AE(X,w2,w3,b2,b3,L2func,L3func)

z2 = w2 * X + b2;                       % Input weight for hidden layer
if(L2func == 'Softplus')                 % a2: Output for hidden layer
    a2 = log(1+exp(z2));               % Sigmoid
elseif(L2func == 'ReLUfnc')
    a2 = zeros(size(z2));               % ReLU
    a2(find(z2>0)) = z2(find(z2>0));
end
z3 = w3 * a2 + b3;                      % Input weight for hidden layer
a3= 1./(1+exp(-z3));                    % Output for hidden layer

end
