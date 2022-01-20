clc, clear, close

% Sample A and B each has 100 observations
data = table2array( readtable('data.csv') );
A = data(:,1); 
B = data(:,2);
N = 100; % number of observation
tab = table();

for i=1:2000
%% Step 1
% randomly select 100 observation from sample A and B
index = datasample(1:N, N ); % sampling with replacement
Ai = A(index);
Bi = B(index);

%% Step 2: calculate cohen's kappa coeffcient

C = confusionmat(Ai,Bi); % confusion matrix
TP = C(2,2);
TN = C(1,1);
FP = C(1,2);
FN = C(2,1);

N = TP+TN+FP+FN; % total observations
Pre = ((TP+FN)/N)*((TP+FP)/N)+(1-(TP+FN)/N)*(1-(TP+FP)/N);

Recall = TP/(TP+FN); % recall (sensitivity)
FPR = FP/(FP+TN); % false positive rate
FNR = FN/(TP+FN); % false negative rate
Specificity = TN/(TN+FP); 

Precision = TP/(TP+FP); % precision
FDR = FP/(TP+FP); % false discovery rate
FOR = FN/(FN+TN);
NPV = TN/(TN+FN); % Negative predictive value

Accuracy = (TP+TN)/N;
F1 = 2*TP/(2*TP+FP+FN); % F-1 score

CK = (((TP+TN)/(TP+TN+FP+FN))-Pre)/(1-Pre); % cohen's kappa
MCC = (TP*TN-FP*FN)/sqrt((TP+FN)*(TP+FP)*(TN+FP)*(TN+FN)); % Matthews correlation coeff.


% save to table
Allmetric = table(Recall,FPR,FNR,Specificity,Precision,FDR,FOR,NPV,...
    Accuracy,F1,MCC,CK);

tab = [tab;Allmetric];

end % Step3: repreated the step 1 and 2 2,000 times


%% Step 4 and Step 5

[ciup,cilow] = CIboot(tab.CK,0.95); % estimate 95% confidence interval
Mean = mean(tab.CK);


histogram(tab.CK); hold on
xline(cilow, '--r')
xline(ciup, '--r')
xline(Mean, '--r')

xlabel('Cohen'' kappa coefficient (\kappa)')
ylabel('No. of simulations')


function [ciup,cilow] = CIboot(data,ci)
    % this function for emprical CI calculation
    % example: [ciup,cilow] = CIboot(data,0.95)

    boundup = ci+(1-ci)/2;
    boundlow = (1-ci)/2;
    [f,x] = ecdf(data); % emprical CDF
    ciup = interp1(f,x,boundup);
    cilow = interp1(f,x,boundlow);
end
    