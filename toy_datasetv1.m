%% Create toy dataset
% rng default % for reproducibility


t   = len; %300;    % Temporal dimension

train  = zeros(N,t);

lon_an = t*0.3;     % Length of the anomaly/ equivale a un tercio de la señal


an_prob = 0.3;      % Probability


%% Generate Nominal dataset for LEARNING
study_case = 1; % Nominal-> case 1: normal signals, case 2: abnormal signals

% Add noise to the nominal data
var0 = 1;
med0 = 0;
an_probN = 0;

switch study_case
    case 1 % m=0 or var =1
        var_normal = 1; % variance NOMINAL
        med_normal = 0; % mean NOMINAL
        
        for i = 1: N
            train(i,:) = normrnd(0,1,1,t)*var_normal + med_normal;
            
            prob = rand(1,1);
            if prob < an_probN
                % ----------- Adding anomalies to the Nominal data -------------%
                ini = randi(t-lon_an,1); %inn1 = [inn1; ini];
                train(i,ini:ini+lon_an-1)  = train(i,ini:ini+lon_an-1)*var0 + med0;
                % --------------------------------------------------------------%
            end
            
        end
        
    case 2 % m!=0 or var !=1
        var_normal = 1.6; % variance NOMINAL
        med_normal = 0; % mean NOMINAL
        
        for i = 1: N
            train(i,:) = normrnd(0,1,1,t);
            
            prob = rand(1,1);
            if prob < an_probN
                % ----------- Adding anomalies to the Nominal data -------------%
                % Do nothing: This is to avoid confusions. The nominal
                % signals have mean value hjumps or variance changes, but
                % the abnormal are zero-mean and unit variance sequences.
                % --------------------------------------------------------------%
            else
                ini = randi(t-lon_an,1);
                train(i,ini:ini+lon_an-1)  = train(i,ini:ini+lon_an-1)*var_normal + med_normal;
                
            end
            
        end
end

%% ----------------------- Generate TEST dataset ----------------------
Ntest = round(N*0.5); % number of new signals

Labels_total   = zeros(Ntest,t);
labels   = zeros(Ntest,1); % Labels_where0 normal, 1 abnormal (antes estaba al revés)

test    = zeros(Ntest,t);
inn     = [];
bb      = 1:t;

%% ---->>>> Mean and variance of ANOMALIES for TEST dataset
% mean_vector = 0; %[1.9, 0.8, 1]; %[0.6,0.8, 1,1.6,2];
% var_vector  = 1.5; %[1.5, 1.9, 2];

anomaly_var = var_vector(1);    % Variance (Abnormal)
anomaly_m   = mean_vector(1);   % mean (Abnormal)

%%
% lon_an = 100;

switch study_case
    case 1
        % La señal normal es N(0,1)
        for i = 1: Ntest
            prob = rand(1,1);
            
            if prob < an_prob % Random injection of anomalies
                % Abnormal signal
                test(i,:) = normrnd(0,1,1,t); % Given that med_normal == 0 && var_normal == 1
                
                ini = randi(t-lon_an,1); inn = [inn; ini];
                
                test(i,ini:ini+lon_an-1)  = test(i,ini:ini+lon_an-1)*anomaly_var + anomaly_m;
                
                labels(i) = 1;
                Labels_total(i,ini:ini+lon_an-1) = 1;
                
            else % Normal signal
                
                test(i,:) = normrnd(0,1,1,t)*var_normal + med_normal; % sin(2*pi*bb/500)+wgn(1,t,0)*var0 + med0; %
            end
        end
        
    case 2
        % m!=0 or var !=1
        % Nota: este tipo de experimento no podría usarse para detectar en
        % el tiempo ya que la señal anormal no tiene perturbancias en el
        % tiempo
        
        for i = 1: Ntest
            
            test(i,:) = normrnd(0,1,1,t);
            prob = rand(1,1);
            
            if prob < an_prob
                % Abnormal is m=0 and var = 1
                labels(i) = 1;
                % In this case, there are no avaiable labels for the
                % anomaly in the time axis, i. e., Z_total
                Labels_total(i,:) = 1;
                
            else % Normal signal
                ini = randi(t-lon_an,1);
                test(i,ini:ini+lon_an-1)  = test(i,ini:ini+lon_an-1)*var_normal + med_normal;
            end
            
            
        end
end
