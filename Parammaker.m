%% For Power Law Fit
clc
close all
%% Imports Data
Import_Data                                                                %Imports data
A=[stage_l1,discharge_l1];                                                 %Creates data matrix
ID=unique(foreign_id);                                                     %Finds the unique foreign ID
%% Loads Initial values
Gr=1;                                                                      %Gr parameter
beta=3;                                                                    %Beta Parameter
%% Optimization Parameters
options = optimset('MaxFunEvals',10000,'TolX',10^-20,'MaxIter',10000,...
    'TolFun',10^-20, 'Display', 'off');                                    %Option set
warning('off','all')                                                       %Hides warnings (from -inf,inf)
tt=1;
%% Curve Fitting
for i=1:length(ID)
    IDnum=ID{i};                                                           %Finds the ith ID
    Loc=find(ismember(foreign_id, IDnum));                                 %Finds the indicies matching ID
    Data=A(Loc,:);                                                         %Finds the data matching id
    if (tt==0)||(tt==2)
        Zer=find(abs(Data(:,2))<10^-8);                                    %Finds zero data
        a=Data(Zer,1);                                                     %Uses the zero as an a value
        x0=[Gr,a,beta];                                                    %Vector of initial values
        [x,fval] = lsqcurvefit(@F,x0,Data(:,1),...
            Data(:,2),-inf,inf,options);                                   %Curve fitting
        Param(i,:)=[x,fval];                                               %Parameter list with error
    end
    if (tt==1)||(tt==2)
        figure
        plot(Data(:,1),Data(:,2),'o')
        hold on
        plot(min(Data(:,1)):.1:max(Data(:,1)),F(Param(i,1:3),...
            (min(Data(:,1)):.1:max(Data(:,1)))))
        Param(i,:)
        pause(.3)
    end
end
%% Save to file
Param_cell=cell(size(Param)+1);                                            %Initializes xls
Param_cell(2:end,1)=ID;                                                    %Inserts Names
Param_cell(1,:)={'foreign_id', 'Gr', 'a', 'beta', 'Square Error'};         %Inserts Column Titles
Param_cell(2:end,2:end)=num2cell(Param);                                   %Inserts Parametes
xlswrite('Parameter_List',Param_cell);                                     %Saves xls