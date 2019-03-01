function plotGPSData( t, x, y, z )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Marshall Herr
%%%
%%% Purpose: Takes in a time vector and position vectors and shows these in
%%% terms of the principal direction of travel, the horizontal direction,
%%% and the "vertical" direction
%%%
%%% Inputs:
%%%     - t: Time vector in seconds
%%%     - x: East position from origin in meters
%%%     - y: North position from origin in meters
%%%     - z: Zenith position from origin in meters
%%%     - u: Eastward velocity from origin in meters per second
%%%     - v: Northward velocity from origin in meters per second
%%%     - w: Zenith-ward velocity from origin in meters per second
%%%
%%% Date Created: 21 Feb 2019
%%% Last Editted: 21 Feb 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Formatting
numBoxes = 100;

% Rotation onto principal, horizontal, vertical axes
% Principal axis is the one which minimizes mean(H) and mean(Z), I.E. it is
% the axis that points along the average position
% Horizontal is the axis perpendicular to Principal with no z component
% Vertical is the remaining axis perpendiculat to both Principal and
% Horizontal
u = [x,y,0.*z];
p = mean(u);
p = p / norm(p);
h = cross( [0,0,1], p );
k = cross( p, h );

P = dot( [x,y,z], p.*ones( size( [x,y,z] ) ), 2 );
H = dot( [x,y,z], h.*ones( size( [x,y,z] ) ), 2 );
K = dot( [x,y,z], k.*ones( size( [x,y,z] ) ), 2 );

% Standard Deviations and Means
sP = std(P);
mP = mean(P);
sH = std(H);
mH = mean(H);
sK = std(K);
mK = mean(K);

% Plotting
figure;

ax = subplot(3,2,1);
plot(t,P)
hold on
plot(t,0.*P+mP,'-g')
plot(t,0.*P+mP+sP,'-r')
plot(t,0.*P+mP-sP,'-r')
ylabel('Principal Position [m]')
title('Position VS Time')
axis tight

subplot(3,2,2);
histfit(P,numBoxes)
y_lim = get(gca,'YLim');
hold on
plot([mP,mP],[y_lim(1),y_lim(2)],'-g')
plot([mP-sP,mP-sP],[y_lim(1),y_lim(2)],'-r')
plot([mP+sP,mP+sP],[y_lim(1),y_lim(2)],'-r')
ylabel('Principal Position Counts')
title('Position Histograms')
ylim(y_lim)

ay = subplot(3,2,3);
plot(t,H)
hold on
plot(t,0.*H+mH,'-g')
plot(t,0.*H+mH+sH,'-r')
plot(t,0.*H+mH-sH,'-r')
ylabel('Horizontal Position [m]')
axis tight

subplot(3,2,4);
histfit(H,numBoxes)
y_lim = get(gca,'YLim');
hold on
plot([mH,mH],[y_lim(1),y_lim(2)],'-g')
plot([mH-sH,mH-sH],[y_lim(1),y_lim(2)],'-r')
plot([mH+sH,mH+sH],[y_lim(1),y_lim(2)],'-r')
ylabel('Horizontal Position Counts')
ylim(y_lim)

az = subplot(3,2,5);
plot(t,K)
hold on
plot(t,0.*K+mK,'-g')
plot(t,0.*K+mK+sK,'-r')
plot(t,0.*K+mK-sK,'-r')
ylabel('Vertical Position [m]')
xlabel('Time [s]')
axis tight

subplot(3,2,6);
histfit(K,numBoxes)
y_lim = get(gca,'YLim');
hold on
plot([mK,mK],[y_lim(1),y_lim(2)],'-g')
plot([mK-sK,mK-sK],[y_lim(1),y_lim(2)],'-r')
plot([mK+sK,mK+sK],[y_lim(1),y_lim(2)],'-r')
ylabel('Vertical Position Counts')
xlabel('Position [m]')
ylim(y_lim)

linkaxes([ax,ay,az],'x')

end