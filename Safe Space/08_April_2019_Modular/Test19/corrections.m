inch_to_m = 0.0254; % m in^-1
% number of CubeSats
correction.nSats = 3;
% global time correction
correction.t = 0; % s

% X: downrange
% Y: left
% Z: up

% ball positions from center of end of kabob
b1_X = (4+1/4+6+1/4+4+5+1/2+4+13/16) * inch_to_m; % m
b1_Y = 0; % m
b1_Z = (3/4) * inch_to_m; % m
b2_X = b1_X + (4+1/2) * inch_to_m; % m
b2_Y = 0; % m
b2_Z = b1_Z; % m
b3_X = b2_X; % m
b3_Y = -((1+3/4)/2) * inch_to_m; % m
b3_Z = 0; % m
b4_X = b2_X; % m
b4_Y = ((1+3/4)/2) * inch_to_m; % m
b4_Z = 0; % m
b5_X = b2_X + (4+1/2) * inch_to_m; % m
b5_Y = 0; % m
b5_Z = b1_Z; % m

% VICON object center from center of end of kabob
B_X = (b1_X+b2_X+b3_X+b4_X+b5_X)/5; % m
B_Y = (b1_Y+b2_Y+b3_Y+b4_Y+b5_Y)/5; % m
B_Z = (b1_Z+b2_Z+b3_Z+b4_Z+b5_Z)/5; % m

% cubesat positions from center of end of kabob
c1_X = ((4+1/4)/2) * inch_to_m; % m
c1_Y = 0; % m
c1_Z = 0; % m
c2_X = c1_X + (6+1/4+(4)/2) * inch_to_m; % m
c2_Y = 0; % m
c2_Z = 0; % m
c3_X = c2_X + (5+1/2+(4)/2) * inch_to_m; % m
c3_Y = 0; % m
c3_Z = 0; % m

% VICON object center to cubesat center
B_to_C1_X = c1_X - B_X; % m
B_to_C1_Y = c1_Y - B_Y; % m
B_to_C1_Z = c1_Z - B_Z; % m
B_to_C2_X = c2_X - B_X; % m
B_to_C2_Y = c2_Y - B_Y; % m
B_to_C2_Z = c2_Z - B_Z; % m
B_to_C3_X = c3_X - B_X; % m
B_to_C3_Y = c3_Y - B_Y; % m
B_to_C3_Z = c3_Z - B_Z; % m

% Extract VANTAGE location wrt system origin
data = dir( './*Pos.csv' );
data = xlsread( [ './', data.name ] );
% crop out header
data = data(5:end,:);
% note x and y are switched for VICON data
O_to_V_X = mean( -data(:,7) ) / 1000 + 0; % m
O_to_V_Y = mean( -data(:,6) ) / 1000 + 69/1000; % m
O_to_V_Z = mean( data(:,8) ) / 1000 - 72/1000; % m
V_to_O_X = -O_to_V_X; % m
V_to_O_Y = -O_to_V_Y; % m
V_to_O_Z = -O_to_V_Z; % m

VCF_to_V_X = 3 / 1000; % m
VCF_to_V_Y = (69-32.498) / 1000; % m
VCF_to_V_Z = (-72+32.498) / 1000; % m

% by not normalizing the VICON output data, O_to_B is simply the first
% position vector of the VICON data and no correction is needed here
O_to_B_X = 0; % m
O_to_B_Y = 0; % m
O_to_B_Z = 0; % m

% CubeSat 1 corrections
correction.x(1) = VCF_to_V_X + V_to_O_X + O_to_B_X + B_to_C1_X; % m
correction.y(1) = -(VCF_to_V_Y + V_to_O_Y + O_to_B_Y + B_to_C1_Y); % m
correction.z(1) = VCF_to_V_Z + V_to_O_Z + O_to_B_Z + B_to_C1_Z; % m
% CubeSat 2 corrections
correction.x(2) = VCF_to_V_X + V_to_O_X + O_to_B_X + B_to_C2_X; % m
correction.y(2) = -(VCF_to_V_Y + V_to_O_Y + O_to_B_Y + B_to_C2_Y); % m
correction.z(2) = VCF_to_V_Z + V_to_O_Z + O_to_B_Z + B_to_C2_Z; % m
% CubeSat 3 corrections
correction.x(3) = VCF_to_V_X + V_to_O_X + O_to_B_X + B_to_C3_X; % m
correction.y(3) = -(VCF_to_V_Y + V_to_O_Y + O_to_B_Y + B_to_C3_Y); % m
correction.z(3) = VCF_to_V_Z + V_to_O_Z + O_to_B_Z + B_to_C3_Z; % m