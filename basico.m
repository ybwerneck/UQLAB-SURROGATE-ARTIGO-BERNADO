%Define input and ouput labels for printing 
qoiLabels = {'ADP90', 'ADP50', 'dVmax', 'Vrest'};

%Load Test and Validation Data

Nt=1500;
Nv=1000;

TrainSet=readmatrix("trainData.txt");

Xtrain=TrainSet(1:Nt,1:8);
Ytrain=TrainSet(1:Nt,9:14);


ValSet=readmatrix("testData.txt");

Xval=ValSet(1:Nv,1:8);
Yval=ValSet(1:Nv,9:14);




%Define model using uqlab


nP=8

 
vals=[150.0 6.0 116.85 11.83425 372.0 5.16 410.0 11.3]; %%baseline values from article
for ii = 1:nP
     InputOpts.Marginals(ii).Type = 'Uniform';
    InputOpts.Marginals(ii).Parameters = [0.7*vals(ii),1.3*vals(ii)]; %% 0.7-1.3 variation
end
myInput = uq_createInput(InputOpts);



%%Define the experiment using uqlab

%%OLS ordinary least square method
MetaOpts.Type = 'Metamodel';
MetaOpts.MetaType = 'PCE';
MetaOpts.Method = 'OLS';
MetaOpts.Degree = 2:3;
MetaOpts.ExpDesign.X = Xtrain;
MetaOpts.ExpDesign.Y = Ytrain;
MetaOpts.ValidationSet.X = Xval;
MetaOpts.ValidationSet.Y = Yval; 


%%Calculate PCE coeficients, we'll perform the adpative experiment,
%%exploring basis of 2:6 degrees, once for each qoi

myPCE = uq_createModel(MetaOpts);

%%Sample validation data with emulator
YPCE = uq_evalModel(myPCE,Xval);
%%Calculate validtion metrics
dif=abs(YPCE-Yval);
meanE=mean((dif));
minE=min((dif));
maxE=max((dif));
corrcoefs=zeros([6,1]);
seldeg=zeros([6,1]);
for ii =1:6
    corrcoefs(ii)=corr(Yval(:,ii),YPCE(:,ii));
    seldeg(ii)=myPCE.PCE(ii).Basis.Degree;
end
avgcoef=mean(corrcoefs);

fprintf("Fitting and validation completed! \n");
fprintf("Selected degrees \n");
disp(seldeg)
fprintf(" \n");
fprintf("Corr Coef \n");
disp(corrcoefs)
fprintf("Avarage: %f \n",avgcoef);
fprintf(" \n");
fprintf("Mins \n");
disp(minE)
fprintf(" \n");
fprintf("Max \n");
disp(maxE)
fprintf(" \n");
fprintf("Mean \n");
disp(meanE)
fprintf(" \n");