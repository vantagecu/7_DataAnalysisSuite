%% Housekeeping
clearvars;
close all;
clc;

%% Trash

[ t, x, y, z ] = importTruthData( './Data/120C.txt' );

x = x - mean(x);
y = y - mean(y);
z = z - mean(z);

x = x.*1000;
y = y.*1000;
z = z.*1000;

figure;

subplot(1,2,1)
hold on
plot(x,y,'.k')

%% Shoutout to my homie Tobin!
% Calculate covariance matrix
P = cov( x, y );
mean_x = mean(x);
mean_y = mean(y);
% Calculate the define the error ellipses
n = 100; % Number of points around ellipse
p = 0 : pi / n : 2 * pi; % angles around a circle
[ eigvec, eigval ] = eig(P); % Compute eigen-stuff
xy_vect = [ cos(p'), sin(p') ] * sqrt(eigval) * eigvec'; % Transformation
x_vect = xy_vect(:,1);
y_vect = xy_vect(:,2);
% Plot the error ellipses overlaid on the same figure
plot( x_vect+mean_x, y_vect+mean_y, 'b', 'LineWidth', 2 )
plot( 2 * x_vect+mean_x, 2 * y_vect+mean_y, 'g', 'LineWidth', 2 )
plot( 3 * x_vect+mean_x, 3 * y_vect+mean_y, 'r', 'LineWidth', 2 )

xlabel( 'East Distance [mm]' )
ylabel( 'North Distance [mm]' )

subplot(1,2,2)
hold on
histfit(z,100)
xlabel( 'Zenith Distance [mm]' )
ylabel( 'Counts' )