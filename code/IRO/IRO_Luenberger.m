% This script is the source code of the IRO method proposed in the paper:
% "Data-driven Input Reconstruction and Experimental Validation"
% by Luenberger design method
clc
clear
close all
rng(127)
%% ====== Initialization ======
% Parameter of the LTI system 
n1 = 20;
A = round(n1*rand(3,3))/10; eig(A)
B = round(n1*rand(3,2))/10;
C = round(n1*rand(3,3))/10;
D =  round(n1*rand(3,2))/10;
nu = size(B, 2);
nx = size(A, 1);
ny = size(C, 1);

% --- Future work
a = tzero(A,B,C,D,eye(nx));
assert(isempty(a) || max(abs(a))<1,'Current framework only works when a<1 or no a!')

fx = @(x,u) A*x + B*u; % state dynamics
fy = @(x,u) C*x + D*u; % output dynamics

% Parameter of the IRO
N_ini = 5;
N_pred = 1;
T = 50; ... T >= (nu + 1)*(N_ini + N_pred + nx) - 1
T_tot = 100; ... total steps for simulation

% Simulate a trajectory by random input
x_cl = zeros(nx,T_tot); y_cl = zeros(ny,T_tot);
Q = eye(nx);R = eye(nu);
[K,~,~] = dlqr(A,B,Q,R);
K = -K;
u_cl = 3*rand(nu,T_tot)-1.5;
x_cl(:, 1) = 0;
u_cl(:,1) = u_cl(:,1) + K*x_cl(:,1);
y_cl(:, 1) =  fy(x_cl(:,1),u_cl(:,1));
for t = 1:T_tot-1
    x_cl(:, t+1) = fx(x_cl(:,t), u_cl(:,t));
    u_cl(:,t+1) = u_cl(:,t+1) + K*x_cl(:,t+1);
    y_cl(:, t+1) = fy(x_cl(:,t+1),u_cl(:,t+1));
end 

% build the Henkal matrix 
disp('Computing Hankel...')
N_total = N_ini + N_pred;
Hankel_col = T - N_total + 1;
Hankel_U = compute_Hankel_matrix(u_cl(:,1:T),nu,N_total, Hankel_col);
Hankel_U_past = Hankel_U(1:nu*N_ini, :);
Hankel_U_future = Hankel_U(nu*N_ini+1:end, :);

% Y: use the same length 
Hankel_Y = compute_Hankel_matrix(y_cl(:,1:T),ny,N_total, Hankel_col);
Hankel_Y_past = Hankel_Y(1:ny*(N_ini), :);
Hankel_Y_future = Hankel_Y(ny*(N_ini)+1:end, :);

%% ====== Check the condition in Theorem 1 ====== 
% Check the Assumption 1: PE condition
N_total = N_ini + N_pred + nx;
Hankel_col = T - N_total +1 ;

% Need: u is persistently exciting of order is N_ini + N_pred + nx
Hankel_U_check = compute_Hankel_matrix(u_cl(:,1:T), nu, N_total, Hankel_col);
if rank(Hankel_U_check)== nu*(N_ini + N_pred + nx) 
    disp('PE condition is ok')
else
    error('Exciting of order of Hu is samller than N_ini + N_pred + nx')
end

% Check nullspace conditin in equation (7)
null_Huy = null([Hankel_U_past;Hankel_Y]);
if max(abs(Hankel_U_future*null_Huy),[],'all')<10^(-5)
    disp('Nullspace condition is OK')
else
    error('Nullspace condition is not satisfied')
end



%% ====== Design Luenberger like IRO ====== 
% (1) get a initial A_UIE
% Use Moore-Penrose pseudoinverse
G1 = pinv([Hankel_U_past;Hankel_Y]); 
U1 = Hankel_U_future*G1(:,1:nu*N_ini);
Y1 = Hankel_U_future*G1(:,nu*N_ini+1:end);
U_check = [zeros(N_ini*nu-nu,nu),eye(N_ini*nu-nu)];
U_check = [U_check; U1];
max(abs(eig(U_check)))

% (2) y_t presented by u_ini and  y_ini
UY2 = Hankel_Y(ny*(N_ini-1)+1:ny*(N_ini), :)*pinv([Hankel_U(1:nu*N_ini, :); Hankel_Y(1:ny*(N_ini-1), :);]);
U2 = UY2(:,1:nu*N_ini);
Y2 = UY2(:,nu*N_ini+1:end);

%(3) Luenberger-like gain
Q = eye(N_ini*nu); 
R = 1;
try
    [K,~,~] = dlqr(U_check',U2',Q,R);
    % check AS by eigenvalues
    abs(eig(U_check'- U2'*K))
    disp('Find a stable IRO')
catch
     error('Can not find a stable IRO!')
end

%% ====== Estimate the input ======
num = size(u_cl,2);
t = T+1;
u_pred(:,1:T) = 0*ones(nu,T);
z_vector = reshape(u_pred(:,t-N_ini:t-1), [N_ini*nu,1]); ... state z for IRO

while(t<=num)
    if t+N_pred-1<=num
        yi = reshape(y_cl(:,t-N_ini:t-1), [(N_ini)*ny,1]); 
        yp = reshape(y_cl(:,t:t+N_pred-1), [N_pred*ny,1]); 
        ui = reshape(u_pred(:,t-N_ini:t-1), [N_ini*nu,1]);

        % Use Luenberger-like IRO
        z_vector =  U_check*z_vector + [zeros(nu*(N_ini-1),size(Y1,2)); Y1]*[yi;yp] + K'*([-Y2 eye(ny)]*yi - U2*z_vector);
        u_pred(:,t:t+N_pred-1) = z_vector(end-nu+1:end,1);

        t = t+N_pred;
    else
        break;
    end
end

%% ====== Plot ======
% Compare input
num = 2;
figure()
hold on; grid on;
start = T+1-5; last = size(u_pred,2);
plot( u_cl(num,start:last), 'Color',[0.4660 0.6740 0.188],'LineWidth',3)
plot( u_pred(num,start:last), '*r--','LineWidth',1)
scatter( [(start:N_pred:last)-start+1],u_cl(num,start:N_pred:last), 100,'blue')
legend('u real','u estimate','Estimation point','FontSize',18)
title('u estimation','fontsize',20)
%%
% Compare input difference
start = T+1; last = size(u_pred,2);
figure(); hold on
plot( u_cl(1,start:last)-u_pred(1,start:last), 'sr-','LineWidth',1)
plot( u_cl(2,start:last)-u_pred(2,start:last), 'sb-','LineWidth',1)
legend('Error u1','Error u2','FontSize',18)
title('Estimation error $u_{closed \ loop} - u_{estimation}$','interpreter', 'latex','fontsize',20)
