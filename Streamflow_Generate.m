Import_Dataset3
Load_Coefficients
ID=intersect(data_name,foreign_id);
for i=1:length(ID)
    IDnum=ID(i);
    Loc_cf=find(ismember(foreign_id, IDnum));                              %Finds the coeff indicies matching ID
    Loc_data=find(ismember(data_name, IDnum));                             %Finds the data indicies matching ID
    Data=Elevation_Data(:,Loc_data);                                       %Finds the data matching ID
    coeff=A(Loc_cf,:);
    Stream(:,i)=F(coeff,Data);
end
[i,j]=size(Stream);
Stream_cell=cell(i+1,j);                                                    %Initializes xls
Stream_cell(1,:)=ID;                                                        %Inserts Column Titles
Stream_cell(2:end,:)=num2cell(Stream);                                      %Inserts Parametes
xlswrite('Streamflow_data',Stream_cell);                                   %Saves xls