# IFIS-Web-Scraping-tool

Site.r        - This tool gathers depth and height data from every sensor indexed for each location from the IFIS available
sites.csv     - This csv contains site names
F.m           - This is a the form of the fitting function
Import_Data.m - This file imports the data from the output.csv file (Change the file location)
ELEVATIONApr_08_20_16_34_2018.csv - Elevation at Apr_08_20_16_34_2018
ELEVATIONApr_12_10_35_16_2018.csv - Elevation at Apr_12_10_35_16_2018
Streamflow_Generate.m - Generates streamflow data from the IFIS Elevation data with paramaters loaded
TDA MAPPER.R - Modified TDA Mapper for KNN and Max Autocorrelation
Parammaker.m - Creates parameters from Stage curve at each location from output.csv
Load_Coefficients.m - Loads parameters from	Parameter_List.xls
Parameter_List.xls - Parameters created from Paramaker
