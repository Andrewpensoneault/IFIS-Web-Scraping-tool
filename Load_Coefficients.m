%% Import data from spreadsheet
%% Import the data
[~, ~, raw] = xlsread('D:\Dropbox\Graduate Classes\UIOWA - 2018 Spring\TDA\Project\Parameter_List.xls','Sheet1','A2:E237');
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,1);
raw = raw(:,[2,3,4,5]);

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
foreign_id = cellVectors(:,1);
A=[data(:,1),data(:,2),data(:,3)];
%% Clear temporary variables
clearvars data raw cellVectors;