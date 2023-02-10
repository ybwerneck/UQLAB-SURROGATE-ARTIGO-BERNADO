clear
uqlab
hold off
clc
%% set results folder
folder="LARS"
mkdir(folder)
folder=folder+"/"
%%Read sets
TrainSet=readmatrix("trainData.txt");
NMAX=1500;
ValSet=readmatrix("testData.txt");
%%Define set sizes to be used
SamplesSizes = 10:10:NMAX; %% 0 to 1500, step 50
[trash,N]=size(SamplesSizes);

%%Define result matrix, one row for each sample size, one column for each qoi
meansE=zeros([N,6]);
maxEs=zeros([N,6]);
minEs=zeros([N,6]);
corrcoefs=zeros([N,6]);
seldegs=zeros([N,6]);
avgcoefs=zeros([N,1]);

[valSetSize,trash]=size(ValSet);

valR=zeros([N,valSetSize,6]);

sblFos=zeros(N,6,8);
sblTos=zeros(N,6,8);

avgs=zeros([N,6]);
stds=zeros([N,6]);
covs=zeros([N,6]);

for ii= 1:N
%%Perform fitting and validation for each sample size
[avgcoef,seldeg,corrcoef,maxE,minE,meanE,em,avg,std,cov,sblFo,sblT]=train_validate(SamplesSizes(ii),false,TrainSet,ValSet);

%%load validation data to main results  matrix
meansE(ii,:)=meanE;
maxEs(ii,:)=maxE;
minEs(ii,:)=minE;
meansE(ii,:)=meanE;
corrcoefs(ii,:)=corrcoef;
seldegs(ii,:)=seldeg;
avgcoefs(ii)=avgcoef;
avgs(ii,:)=avg;
covs(ii,:)=cov;
stds(ii,:)=std;

sblFos(ii,:,:)=sblFo;
sblTos(ii,:,:)=sblT;
valR(ii,:,:)=em;

end

clc

for ii = 1:6
    subplot(2,3,ii);
    [coef,melhor]=max(corrcoefs(:,ii));
    MM(ii,1:4)=[ii,seldegs(melhor,ii),coef,SamplesSizes(melhor)];
    MF(ii,:)=sblFos(melhor,ii,:);
    MT(ii,:)=sblTos(melhor,ii,:);
    T(1:3,ii)= [avgs(melhor,ii),stds(melhor,ii),covs(melhor,ii) ];
    fprintf("\n For qoi %d, best emulator was n %d \n",ii,melhor);
    fprintf("Sobol")
    firstorder=sblFos(melhor,ii,:);
    Torder=sblTos(melhor,ii,:);
    bar(reshape(Torder,[1,8]),'b');
    hold on
    bar(reshape(firstorder,[1,8]),'g');
    hold off
    fprintf(" \n");
    legend( 'Total Order','First order');

end 
saveas(gcf,folder+"sobol.png")
header={'#X1','X2','X3','X4','X5','X6','X7','X8'};
writecell([header;num2cell(MF)],folder+'SobolFirsOrderData.xls')
writecell([header;num2cell(MF)],folder+'SobolTotalOrderData.xls')
header={'#QOI','SEL DEG','CORR COEF',"Samples"};
writecell([header;num2cell(MM)],folder+'Selected_bestPCE_data.xls')

header={'#QOI1','QOI2', 'QOI3','QOI4',"QOI5",'QOI6'};
writecell([header;num2cell(T)],folder+'Table3.xls')


for ii = 1:6
    subplot(2,3,ii);
    [coef,melhor]=max(corrcoefs(:,ii));
    fprintf("\n For qoi %d, best emulator was n %d \n",ii,melhor);
    fprintf("Sobol")
    firstorder=sblFos(melhor,ii,:);
    Torder=sblTos(melhor,ii,:);
    hist(valR(melhor,:,ii));
    M(:,ii)=valR(melhor,:,ii);
    fprintf(" \n");
    

end 
saveas(gcf,folder+"hist.png")
header={'#QOI1','QOI2', 'QOI3','QOI4',"QOI5",'QOI6'};
writecell([header;num2cell(M)],folder+'HistData.xls')

fprintf("Fitting and validation completed for all Sample Sizes! \n");
fprintf("Sample Sizes used \n");
disp(SamplesSizes)
fprintf(" \n");
fprintf("Selected degrees  \n");
disp(seldegs)
fprintf(" \n");
fprintf("Corr Coefs \n");
disp(corrcoefs)
fprintf("Avarage \n")
disp(avgcoefs);
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


clf

figure('Position', [100, 100, 800, 600])
%%plot metrics
for ii = 1:6
   subplot(2,3,ii);
   
   
  
   yyaxis left
   

   MD(:,ii)=seldegs(:,ii);
   MC(:,ii)=corrcoefs(:,ii);

   plot(SamplesSizes,corrcoefs(:,ii))
   axis([ 0 NMAX+10 0.2  1.1]);
   ylabel("Avg Rsqr");
   hold on
   
   yyaxis right
   
   plot(SamplesSizes,seldegs(:,ii))
   axis([ 0 NMAX+10 0  7]);
   ylabel("Selected degree");
   xlabel("Training set size")
   for kk = 3:4
       for jj=1:4
        xline(factorial(8+kk)/(factorial(8)*factorial(kk))*jj,'--b',label="D"+kk+" m"+jj,fontsize = 6,LabelHorizontalAlignment='left')
       end
   end
   hold off

end 

SA=SamplesSizes;

saveas(gcf,folder+ "metrics.png")
header={'#QOI1','QOI2', 'QOI3','QOI4',"QOI5",'QOI6'};
writecell([header;num2cell(MD)],folder+'Selected_Degree_Data.xls');
writecell([header;num2cell(MC)],folder+'CorreCoefs_Data.xls');
writematrix(SA,folder+"Samples_Size_used.xls");
clf
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

saveas(gcf,folder+"meanerr.png")


%%Choose best emulator for each metric and perfom aditiional validataion 
clf

for ii = 1:6
    subplot(2,3,ii);
    [coef,melhor]=max(corrcoefs(:,ii));
    fprintf("\n For qoi %d, best emulator was n %d \n",ii,melhor);
    fprintf("Generated using %d samples, and basis of %d degree \n",SamplesSizes(melhor),seldegs(melhor,ii));
    fprintf("Coef %f Mean Err %f \n",coef,meansE(melhor,ii));
    fprintf(" \n");
    val=ValSet(:,8+ii); %% dislocate 8 for inputs
    pred=valR(melhor,:,ii);
    
    scatter(pred,val,60,'filled');
    axis([ min(val) max(val) min(val)  max(val) ]);
    hold on
    plot(val,val,'black','LineWidth',2);
    hold off
    xlabel("Ytrue");
    ylabel("Ypred");
end 
saveas(gcf,folder+"scatter.png")
