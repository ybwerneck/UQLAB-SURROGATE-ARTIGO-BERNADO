uqlab
hold off
clc
%%Read sets
TrainSet=readmatrix("trainData.txt");
NMAX=1500;
ValSet=readmatrix("testData.txt");
%%Define set sizes to be used
SamplesSizes = 10:50:NMAX; %% 0 to 1500, step 50
[trash,N]=size(SamplesSizes);

%%Define result matrix, one row for each sample size, one column for each qoi
meansE=zeros([N,6]);
maxEs=zeros([N,6]);
minEs=zeros([N,6]);
corrcoefs=zeros([N,6]);
seldegs=zeros([N,6]);
avgcoefs=zeros([N,1]);
valR={} ;

for ii= 1:N
%%Perform fitting and validation for each sample size
[avgcoef,seldeg,corrcoef,maxE,minE,meanE,em]=train_validate(SamplesSizes(ii),false,TrainSet,ValSet);

%%load validation data to main results  matrix
meansE(ii,:)=meanE;
maxEs(ii,:)=maxE;
minEs(ii,:)=minE;

meansE(ii,:)=meanE;
corrcoefs(ii,:)=corrcoef;
seldegs(ii,:)=seldeg;
avgcoefs=avgcoef;

valR=[valR,em];
end
clc
fprintf("Fitting and validation completed for all Sample Sizes! \n");
fprintf("Sample Sizes used \n");
disp(SamplesSizes)
fprintf(" \n");
fprintf("Selected degrees  \n");
disp(seldegs)
fprintf(" \n");
fprintf("Corr Coefs \n");
disp(corrcoefs)
fprintf("Avarage: %f \n",avgcoefs);
fprintf(" \n");
fprintf("Min Erros \n");
disp(minEs)
fprintf(" \n");
fprintf("Max  Erros \n");
disp(maxEs)
fprintf(" \n");
fprintf("Mean   Erros\n");
disp(meansE)
fprintf(" \n");


clc
figure('Position', [100, 100, 800, 600])
%%plot metrics
for ii = 1:6
   subplot(2,3,ii);
   
   
  
   yyaxis left
   

  
   plot(SamplesSizes,corrcoefs(:,ii))
   axis([ 0 NMAX 0.2  1.1]);
   ylabel("Avg Rsqr");
   hold on
   
   yyaxis right

   plot(SamplesSizes,seldegs(:,ii))
   axis([ 0 NMAX 0  7]);
   ylabel("Selected degree");
   xlabel("Training set size")
   hold off

end 

saveas(gcf,"metrics.png")
clc
figure('Position', [100, 100, 800, 600])
%%plot metrics
for ii = 1:6
   subplot(2,3,ii);
   
   
  
   yyaxis left
   

   
   plot(SamplesSizes,meansE(:,ii))
   axis([ 0 NMAX -0.01  1.1*max(meansE(:,ii))]);
   ylabel("Mean Err");
   hold on
   
   yyaxis right

   plot(SamplesSizes,seldegs(:,ii))
   axis([ 0 NMAX 0  7]);
   ylabel("Selected degree");
   xlabel("Training set size")
   hold off

end 

saveas(gcf,"meanerr.png")
%%Choose best emulator for each metric and perfom aditiional validataion 
clf

for ii = 1:6
    subplot(2,3,ii);
    [coef,melhor]=max(corrcoefs(:,ii));
    fprintf("\n For qoi %d, best emulator was n %d \n",ii,melhor);
    fprintf("Generated using %d samples, and basis of %d degree \n",SamplesSizes(melhor),seldegs(melhor,ii));
    fprintf("Coef %f Mean Err %f \n",coef,meansE(melhor,ii));
    fprintf(" \n");
    a=cell2mat(valR(melhor) );
    val=ValSet(:,8+ii); %% dislocate 8 for inputs
    pred=a(:,ii);
    
    scatter(pred,val,60,'filled');
    axis([ min(val) max(val) min(val)  max(val) ]);
    hold on
    plot(val,val,'black','LineWidth',2);
    hold off
    xlabel("Ytrue");
    ylabel("Ypred");
end 
saveas(gcf,"scatter.png")