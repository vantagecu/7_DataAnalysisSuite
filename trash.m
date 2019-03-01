%% Housekeeping
clearvars;
close all;
clc;

%% Trash

filepath = '610.txt';
% delimiter = ' ';
% headerRowNumber = 1;

[ t, x, y, z, u, v, w ] = importTrimbleData( filepath );

% Stop
plotGPSData(t,x,y,z)
plotGPSData(t,u,v,w)

return
livePlot( t, x, y, z )

%{
Order:
UI -> Pick GPS File
UI -> Show RAW data
    Options: Clean (sigma removal), Manual Deletion, Specify Start Time
UI -> Pick VANTAGE File
UI -> Overlay both with best fit lines
???
Profit
%}