function [precision_py_,recall_py_,AUC,thresholds_] = precision_recall_curve(y_true,y_score)

% Function adapted from the python function
% Kareth Leon - Noviembre 14, 2020

% python-based
% cl_tru = unique(y_true);

% _binary_clf_curve
[~,desc_score_indices] = sort(y_score,'descend');

% sort scores and corresponding truth values
y_score = y_score(desc_score_indices);
y_true = y_true(desc_score_indices); % Acá está la diferencia
weight = 1;

distinct_value_indices = find(diff(y_score));
threshold_idxs = 1:length(distinct_value_indices); % linspace(1,length(y_score),length(distinct_value_indices));


% # accumulate the true positives with decreasing threshold
tps = cumsum(y_true*weight);
tps = tps(threshold_idxs);

fps =  threshold_idxs - tps; % quité el +1 por el inicio de 1 en matlab e inicio 0 en python
thresholds = y_score(threshold_idxs);

% ----------------------------------------------------------%
precision_py = tps ./ (tps + fps);
idp = find(isnan(precision_py));
precision_py(idp) = 0;

recall_py = tps./tps(end);

last_ind = find(tps==tps(end),1);

precision_py_ = [precision_py(last_ind:-1:1),1]; % de 0 a 1
recall_py_ = [recall_py(last_ind:-1:1),0]; % de 1 a 0
thresholds_ = thresholds(last_ind:-1:1);

AUC = -trapz(recall_py_,precision_py_);  %-sum(diff(recall_py_) * precision_py_(end))
