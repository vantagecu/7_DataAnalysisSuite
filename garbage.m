clearvars;
close all;
clc;

done = 0;

% path = './Data/';
% filename = '550.txt.';

while ~done
    
    msg = msgbox( 'Choose a GPS file.', 'GPS INPUT' );
    
    waitfor( msg )
    
    [ filename, path ] = uigetfile( '*.txt' );
    
    if ~path
        
        return
        
    end
    
    answer = questdlg( [ 'Is ''', filename, ''' correct?' ], ...
        'GPS CHECK', 'Yes', 'No', 'Cancel', 'Yes' );
    
    switch answer
        case 'Yes'
            
            done = 1;
            
        case 'Cancel'
            
            return
            
    end
    
end

[ t, x, y, z, u, v, w ] = importTrimbleData( [ path, filename ] );

% Rotation onto principal, horizontal, vertical axes
% Principal axis is the one which minimizes mean(H) and mean(Z), I.E. it is
% the axis that points along the average position
% Horizontal is the axis perpendicular to Principal with no z component
% Vertical is the remaining axis perpendiculat to both Principal and
% Horizontal
p = [x,y,0.*z];
p = mean(p);
p = p / norm(p);
h = cross( [0,0,1], p );
k = cross( p, h );

p = dot( [x,y,z], p.*ones( size( [x,y,z] ) ), 2 );
h = dot( [x,y,z], h.*ones( size( [x,y,z] ) ), 2 );
k = dot( [x,y,z], k.*ones( size( [x,y,z] ) ), 2 );

f = figure( 'MenuBar', 'none', 'ToolBar', 'figure', ...
    'DockControls', 'off', 'WindowState', 'maximized', ...
    'Name', 'GPS DATA', 'NumberTitle', 'off', ...
    'CloseRequestFcn', @my_closereq );

a1 = subplot(1,2,1);
% this will hold a 3D map of the GPS PHK Data
hold on
colormap(fliplr(jet))
scatter3( p, h, k, 1, t )
a1.PlotBoxAspectRatioMode = 'manual';
a1.DataAspectRatioMode = 'manual';
grid on
xlabel( 'Principal Position [m]' )
ylabel( 'Horizontal Position [m]' )
zlabel( 'Zenith Position [m]' )
view( [45,45] )

ax = subplot(3,2,2);
% this will hold an P vs T graph
hold on
scatter3( t, p, 0.*t, 1, t )
grid on
xlabel( 'Time [s]' )
ylabel( 'Principal Position [m]' )
view( [0,90] )

ay = subplot(3,2,4);
% this will hold an H vs T graph
hold on
scatter3( t, h, 0.*t, 1, t )
grid on
xlabel( 'Time [s]' )
ylabel( 'Horizontal Position [m]' )
view( [0,90] )

az = subplot(3,2,6);
% this will hold an K vs T graph
hold on
scatter3( t, k, 0.*t, 1, t )
grid on
xlabel( 'Time [s]' )
ylabel( 'Zenith Position [m]' )
view( [0,90] )

linkaxes( [ ax, ay, az ], 'x' )

done = 0;

while ~done
    
    answer = questdlg( 'Data Meet Requirement?', '', ...
        'Good Enough', '>_<', 'Good Enough' );
    
    switch answer
        case '>_<'
            
            f_Width = f.Position(3) - f.Position(1) + 1;
            f_Height = f.Position(4) - f.Position(2) + 1;
            
            a1_center = [ a1.Position(1) + a1.Position(3)/2, ...
              a1.Position(2) + a1.Position(4)/2 ];
            
            ax_center = [ ax.Position(1) + ax.Position(3)/2, ...
                          ax.Position(2) + ax.Position(4)/2 ];
            
            ay_center = [ ay.Position(1) + ay.Position(3)/2, ...
                          ay.Position(2) + ay.Position(4)/2 ];
            
            az_center = [ az.Position(1) + az.Position(3)/2, ...
                          az.Position(2) + az.Position(4)/2 ];
            
            msg = msgbox( 'Click on the datapoint to select it.' );
            
            waitfor( msg )
            
            waitforbuttonpress;
            
            cp = f.CurrentPoint ./ [ f_Width, f_Height ];
            
            dist1 = norm( cp - a1_center );
            distx = norm( cp - ax_center );
            disty = norm( cp - ay_center );
            distz = norm( cp - az_center );
            
            [ ~, idx ] = min( [ dist1, distx, disty, distz ] );
            
            switch idx
                case 1
                    f.CurrentAxes = a1;
                case 2
                    f.CurrentAxes = ax;
                case 3
                    f.CurrentAxes = ay;
                case 4
                    f.CurrentAxes = az;
            end
            
            cp = f.CurrentAxes.CurrentPoint;
            
            p1 = cp(1,:);
            p2 = cp(2,:);
            vec = p2 - p1;
            r = [ f.CurrentAxes.Children.XData; ...
                  f.CurrentAxes.Children.YData; ...
                  f.CurrentAxes.Children.ZData ]';
            
            vec_dot_rp = vec(1) .* ( r(:,1) - p1(1) ) + ...
                         vec(2) .* ( r(:,2) - p1(2) ) + ...
                         vec(3) .* ( r(:,3) - p1(3) );
            
            rp_proj_vec = [ vec(1) .* vec_dot_rp, ...
                            vec(2) .* vec_dot_rp, ...
                            vec(3) .* vec_dot_rp ] ./ norm( vec ).^2;
            
            dist = ( r - p1 ) - rp_proj_vec;
            
            % normalizing dist: VERY IMPORTANT
            xr = diff( f.CurrentAxes.XLim );
            yr = diff( f.CurrentAxes.YLim );
            zr = diff( f.CurrentAxes.ZLim );
            dist = [ dist(:,1) ./ xr, dist(:,2) ./ yr, dist(:,3) ./ zr ];
            
            dist = sqrt( dist(:,1).^2 + dist(:,2).^2 + dist(:,3).^2 );
            
            idx = dist == min(dist);
            
            p1 = plot3( a1, p(idx), h(idx), k(idx), 'xm' );
            px = plot3( ax, t(idx), p(idx), 0.*t(idx), 'xm' );
            py = plot3( ay, t(idx), h(idx), 0.*t(idx), 'xm' );
            pz = plot3( az, t(idx), k(idx), 0.*t(idx), 'xm' );
            
            answer = questdlg( 'Is this the correct data point?', ...
                'SELECTED POINT', 'Yes', 'No', 'Yes' );
            
            if strcmpi( 'No', answer )
                delete(p1)
                delete(px)
                delete(py)
                delete(pz)
                continue
            end
            
            answer = questdlg( 'What should be deleted?', ...
                'DELETE POINT', 'Everything Right', 'Everything Left', ...
                'Just This', 'Just This' );
            
            delete(p1)
            delete(px)
            delete(py)
            delete(pz)
            
            switch answer
                case 'Everything Right'
                    
                    t = t(1:find(idx));
                    p = p(1:find(idx));
                    h = h(1:find(idx));
                    k = k(1:find(idx));
                    u = u(1:find(idx));
                    v = v(1:find(idx));
                    w = w(1:find(idx));
                    
                case 'Everything Left'
                    
                    t = t(find(idx):end);
                    p = p(find(idx):end);
                    h = h(find(idx):end);
                    k = k(find(idx):end);
                    u = u(find(idx):end);
                    v = v(find(idx):end);
                    w = w(find(idx):end);
                    
                case 'Just This'
                    
                    t = t(~idx);
                    p = p(~idx);
                    h = h(~idx);
                    k = k(~idx);
                    u = u(~idx);
                    v = v(~idx);
                    w = w(~idx);
                    
                otherwise
                    
                    continue
                    
            end
            
            clf
            
            a1 = subplot(1,2,1);
            % this will hold a 3D map of the GPS PHK Data
            hold on
            colormap(fliplr(jet))
            scatter3( p, h, k, 1, t )
            a1.PlotBoxAspectRatioMode = 'manual';
            a1.DataAspectRatioMode = 'manual';
            grid on
            xlabel( 'Principal Position [m]' )
            ylabel( 'Horizontal Position [m]' )
            zlabel( 'Zenith Position [m]' )
            view( [45,45] )
            
            ax = subplot(3,2,2);
            % this will hold an P vs T graph
            hold on
            scatter3( t, p, 0.*t, 1, t )
            grid on
            xlabel( 'Time [s]' )
            ylabel( 'Principal Position [m]' )
            view( [0,90] )
            
            ay = subplot(3,2,4);
            % this will hold an H vs T graph
            hold on
            scatter3( t, h, 0.*t, 1, t )
            grid on
            xlabel( 'Time [s]' )
            ylabel( 'Horizontal Position [m]' )
            view( [0,90] )
            
            az = subplot(3,2,6);
            % this will hold an K vs T graph
            hold on
            scatter3( t, k, 0.*t, 1, t )
            grid on
            xlabel( 'Time [s]' )
            ylabel( 'Zenith Position [m]' )
            view( [0,90] )
            
            linkaxes( [ ax, ay, az ], 'x' )
            
        case 'Good Enough'
            
            done = 1;
            
    end
    
end

f.CloseRequestFcn = 'closereq';
close(f)

plotGPSData(t,p,h,k)
plotGPSData(t,u,v,w)














function my_closereq( src, ~ )
    % Close request function 
    % to display a question dialog box 
   selection = questdlg( 'Quit?', '', 'Yes', 'No', 'Yes' ); 
   
   switch selection
      case 'Yes'
         delete(src)
      case 'No'
      return 
   end
   
end