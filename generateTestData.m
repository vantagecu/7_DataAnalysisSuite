function [ V_t, V_x, V_y, V_z, T_t, T_x, T_y, T_z ] = ...
    generateTestData( n, scale, mu_t, sigma_t, mu_x, sigma_x, mu_y, ...
    sigma_y, mu_z, sigma_z )

% n samples of a uniform distribution between a and b
unif = @(n,a,b) (b-a) .* rand(n,1) + a;
[ T_t, T_x, T_y, T_z ] = deal( linspace( 0, scale, 1000 )' );

% add random noise to x, y, z data
V_x = T_x + unif( n, -sigma_x .* T_x, sigma_x .* T_x );
V_y = T_y + unif( n, -sigma_y .* T_y, sigma_y .* T_y );
V_z = T_z + unif( n, -sigma_z .* T_z, sigma_z .* T_z );
T_x = T_x + unif( n, -sigma_x, sigma_x );
T_y = T_y + unif( n, -sigma_x, sigma_x );
T_z = T_z + unif( n, -sigma_x, sigma_x );

% add offset to t, x, y, z data
V_t = T_t + unif( 1, mu_t - sigma_t, mu_t + sigma_t );
T_x = T_x + mu_x;
T_y = T_y + mu_y;
T_z = T_z + mu_z;

% add a random rotation
R_x = @(t) [ 1, 0, 0; 0, cos(t), -sin(t); 0, sin(t), cos(t) ];
R_y = @(t) [ cos(t), 0, sin(t); 0, 1, 0; -sin(t), 0, cos(t) ];
R_z = @(t) [ cos(t), -sin(t), 0; sin(t), cos(t), 0; 0, 0, 1 ];

a = unif(1,0,2*pi);
b = unif(1,0,2*pi);
c = unif(1,0,2*pi);
R = R_x(a) * R_y(b) * R_z(c);

for i = 1 : n
    v = [ V_x(i); V_y(i); V_z(i) ];
    v = R * v;
    V_x(i) = v(1);
    V_y(i) = v(2);
    V_z(i) = v(3);
end

end