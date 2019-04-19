%% Housekeeping
clearvars;
close all;
clc;

%% Setup for Testing
d_start = 20;
d_end = 40;

n = 1000;
scale = 100;
mu_t = 0;
mu_x = 10;
mu_y = 7;
mu_z = 3;
sigma_t = 100;
sigma_x = 1/5;
sigma_y = 1/4;
sigma_z = 1/10;

[ V_t, V_x, V_y, V_z, T_t, T_x, T_y, T_z ] = ...
    generateTestData( n, scale, mu_t, sigma_t, mu_x, sigma_x, mu_y, ...
    sigma_y, mu_z, sigma_z );

T_color = zeros(n,3);
idx_start = 0;
idx_end = 0;

for i = 1 : n
    T_d = norm( [ T_x(i), T_y(i), T_z(i) ] );
    T_color(i,1) = +( ( T_d > d_start ) & ( T_d < d_end ) );
    V_d = norm( [ V_x(i), V_y(i), V_z(i) ] );
    if (~idx_start) && (V_d > d_start)
        idx_start = i;
    end
    if (~idx_end) && (V_d > d_end)
        idx_end = i;
    end
end

% crop V data
V_t = V_t(idx_start:idx_end);
V_x = V_x(idx_start:idx_end);
V_y = V_y(idx_start:idx_end);
V_z = V_z(idx_start:idx_end);

VANTAGE_Data.t = V_t;
VANTAGE_Data.x = V_x;
VANTAGE_Data.y = V_y;
VANTAGE_Data.z = V_z;
V_d = sqrt(VANTAGE_Data.x.^2+VANTAGE_Data.y.^2+VANTAGE_Data.z.^2);
VANTAGE_Data.d = [ min(V_d), max(V_d) ];
Truth_Data.t = T_t;
Truth_Data.x = T_x;
Truth_Data.y = T_y;
Truth_Data.z = T_z;

figure;
scatter3(V_x,V_y,V_z,1,'r')
hold on
scatter3(T_x,T_y,T_z,1,T_color)
title('Initial')

%% function time
[ dt, theta, n_vec, offset_vec, Truth_Data ] = ...
    ImRunningOutOfNames( VANTAGE_Data, Truth_Data, 1 );