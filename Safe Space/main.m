%% Main menu
clc

while 1
% Housekeeping
clearvars -except path

list = { 'Import Truth Data', 'Plot Truth Data', 'Display Corrections' };
answer = listdlg( 'PromptString', 'Choose Action', 'ListString', ...
    list, 'SelectionMode', 'Single' );

% answer will be one of the following: 1,2,3,[]
% each number corresponds to the choice selected
% [] indicates closed out or cancelled

if isempty( answer ) % canceled/closed out
    disp( 'Exiting.' )
    return
end

disp( [ list{answer}, ' selected.' ] )

% 1-2 has been selected
if answer < 3
    msg_str = 'Select Test Folder.';
else % 3 selected
    msg_str = 'Select Corrections Folder.';
end

m = msgbox( msg_str );
waitfor(m)

if ~exist( 'path', 'var' )
    path = '';
end

path = uigetdir( path );

if ~path
    disp( 'Cancelling.' )
    clearvars path
    continue
end

disp( [ path, ' selected as folder.' ] )

truth_name = [ path, '/truth.json' ];

% now is the time to separate out choices
% 1: Import Truth Data
% 2: Plot Truth Data
% 3: Display Corrections
switch answer
    case 1
        % check for pre-expisting truth file
        if exist( truth_name, 'file' )
            warning( 'Truth file already exists.' )
            answer = questdlg( [ 'Truth file already exists. ', ...
                'Delete it and continue?' ], 'WARNING', 'Yes', 'No', ...
                'No' );
            switch answer
                case 'Yes'
                    delete(truth_name)
                    disp( [ truth_name, ' deleted.' ] )
                otherwise
                    disp( [ truth_name, ' not deleted.' ] )
                    disp( 'Import Truth Data canceled.' )
                    continue
            end
        end
        
        % import raw truth data
        [ t, x, y, z, date_str ] = importTruthData( path );
        
        % if import was cancelled
        if isempty(t)
            disp( 'Import Truth Data canceled.' )
            continue
        end
        
        % import correction
        if exist( [ path, '/corrections.m' ], 'file' )
            run( [ path, '/corrections.m' ] )
            % this loads the data in correction.m:
            % a struct called "correction" with the fields:
            % - nSats: the number of CubeSats
            % - t: The time correction to the truth data
            % - x(i): the X correction for cubesat i
            % - y(i): the Y correction for cubesat i
            % - z(i): the Z correction for cubesat i
            % correction.x/y/z are nSats long
            
        else % correction.m file does not exist
            warning( 'No corrections file found.' )
            answer = questdlg( [ 'No corrections file found. ', ...
                'Import truth data as 1 CubeSat with no corrections?' ],...
                'WARNING', 'Yes', 'No', 'Yes' );
            
            switch answer
                case 'Yes'
                    disp( [ 'Continuing with 1 CubeSat and no ', ...
                        'corrections to Truth Data.' ] )
                    correction.nSats = 1;
                    correction.t = 0;
                    correction.x = 0;
                    correction.y = 0;
                    correction.z = 0;
                    
                case 'No'
                    disp( 'Import Truth Data canceled.' )
                    continue
                    
                otherwise
                    disp( [ '¯\\_(', char(12471), ...
                        ')_/¯ guess I''ll die...' ] )
                    error( [ 'Tell Marshall his code is jank and how ', ...
                        'you got here.' ] )
                    
            end
        end
        
        % generate truth struct
        if imag( correction.t ) % imaginary value for datestr
            date_str = datestr( imag( correction.t ), 'dd-mmm-yyyy HH:MM:SS.FFF' );
        else
            t = t + correction.t;
        end
            
        
        for i = 1 : length(t)
            truth(i).t = t(i);
            for j = 1 : correction.nSats
                truth(i).pos.( [ 'CubeSat_', num2str(j) ] ) = ...
                    [ -( y(i) + correction.y(j) ); ...
                    -( z(i) + correction.z(j) ); ...
                    x(i) + correction.x(j) ];
            end
        end
        
        % generate truth file
        fID = fopen( truth_name, 'w' );
        jason = jsonencode( { date_str, truth } );
        fprintf( fID, jason );
        fclose(fID);
        disp( 'Import Truth Data complete.' )
        
    case 2
        
        % check for truth file existance
        if ~exist( truth_name, 'file' )
            warning( 'Truth file does not exist.' )
            w = warndlg( 'Truth file does not exist.' );
            waitfor(w)
            disp( 'Plot Truth Data cancelled.' )
            continue
        end
        
        % extract truth data
        truth = jsondecode( fileread( truth_name ) );
        date_str = truth{1};
        truth = truth{2};
        % number of datapoints
        for i = 1 : length( truth )
            % number of CubeSats
            t(i) = truth(i).t;
            for j = 1 : length( truth(1).pos )
                x{j}(i) = truth(i).pos.( [ 'CubeSat_', num2str(j) ] )(1);
                y{j}(i) = truth(i).pos.( [ 'CubeSat_', num2str(j) ] )(2);
                z{j}(i) = truth(i).pos.( [ 'CubeSat_', num2str(j) ] )(3);
            end
        end
        
        f = figure;
        for i = 1 : length( truth(1).pos )
            plotTruthData( t, x{i}, y{i}, z{i} )
        end
        
        waitfor(f)
        disp( 'Plot Truth Data complete.' )
        
        % It would probably behoove me to figure out a way of either
        % labelling all nSat lines in this figure, plotting nSat figures,
        % or something else to make looking at all nSat sats reasonably
        % understandable.
        
    case 3
        
        fileSearch = [ path, '/*.mat' ];
        fileStruct = dir(fileSearch);
        numFiles = length(fileStruct);
        
        % if no files found
        if ~numFiles
            w = warndlg( 'No correction files found' );
            waitfor(w)
            warning( [ 'No correction files found in ', path ] )
        disp( 'Display Corrections canceled.' )
            continue
        end
        
        % initialization
        fileName = cell(numFiles,1);
        
        for i = 1 : numFiles
            
            fileName{i} = fileStruct(i).name;
            dataStruct = load( [ path, '/', fileName{i} ] );
            % lol
            dataStruct = dataStruct.dataStruct;
            corrections(i) = dataStruct;
            
        end
        
        [corrections.fileName] = fileName{:};
        
        [ p1, p2, p3, p4, p5, p6, p7, p8 ] = deal( gobjects( numFiles, 1 ) );
        
        f = figure;
        a1 = subplot(2,4,1);
        hold on
        a2 = subplot(2,4,5);
        hold on
        a3 = subplot(2,4,2);
        hold on
        a4 = subplot(2,4,3);
        hold on
        a5 = subplot(2,4,4);
        hold on
        a6 = subplot(2,4,6);
        hold on
        a7 = subplot(2,4,7);
        hold on
        a8 = subplot(2,4,8);
        hold on
        
        for i = 1 : numFiles
            
            numElements = length(corrections(i).dt);
            [ dt, theta ] = deal( NaN .* ones( 1, numElements ) );
            [ n_vec, offset_vec ] = deal( NaN .* ones( 3, numElements ) );
            
            for j = 1 : numElements
                
                dt(j) = corrections(i).dt{j};
                n_vec(:,j) = corrections(i).n_vec{j};
                theta(j) = corrections(i).theta{j};
                offset_vec(:,j) = corrections(i).offset_vec{j};
                
            end
            
            p1(i) = plot(a1,dt,'-o','LineWidth',2,'MarkerSize',10);
            p2(i) = plot(a2,theta,'-o','LineWidth',2,'MarkerSize',10);
            p3(i) = plot(a3,n_vec(1,:),'-o','LineWidth',2,'MarkerSize',10);
            p4(i) = plot(a4,n_vec(2,:),'-o','LineWidth',2,'MarkerSize',10);
            p5(i) = plot(a5,n_vec(3,:),'-o','LineWidth',2,'MarkerSize',10);
            p6(i) = plot(a6,offset_vec(1,:),'-o','LineWidth',2,'MarkerSize',10);
            p7(i) = plot(a7,offset_vec(2,:),'-o','LineWidth',2,'MarkerSize',10);
            p8(i) = plot(a8,offset_vec(3,:),'-o','LineWidth',2,'MarkerSize',10);
            
        end
        
        legend(a1,p1,{corrections.fileName},'Location','best','Interpreter','none')
        legend(a2,p2,{corrections.fileName},'Location','best','Interpreter','none')
        legend(a3,p3,{corrections.fileName},'Location','best','Interpreter','none')
        legend(a4,p4,{corrections.fileName},'Location','best','Interpreter','none')
        legend(a5,p5,{corrections.fileName},'Location','best','Interpreter','none')
        legend(a6,p6,{corrections.fileName},'Location','best','Interpreter','none')
        legend(a7,p7,{corrections.fileName},'Location','best','Interpreter','none')
        legend(a8,p8,{corrections.fileName},'Location','best','Interpreter','none')
        
        a1.XLabel.Interpreter = 'none';
        a1.YLabel.Interpreter = 'none';
        a1.Title.Interpreter = 'none';
        a2.XLabel.Interpreter = 'none';
        a2.YLabel.Interpreter = 'none';
        a2.Title.Interpreter = 'none';
        a3.XLabel.Interpreter = 'none';
        a3.YLabel.Interpreter = 'none';
        a3.Title.Interpreter = 'none';
        a4.XLabel.Interpreter = 'none';
        a4.YLabel.Interpreter = 'none';
        a4.Title.Interpreter = 'none';
        a5.XLabel.Interpreter = 'none';
        a5.YLabel.Interpreter = 'none';
        a5.Title.Interpreter = 'none';
        a6.XLabel.Interpreter = 'none';
        a6.YLabel.Interpreter = 'none';
        a6.Title.Interpreter = 'none';
        a7.XLabel.Interpreter = 'none';
        a7.YLabel.Interpreter = 'none';
        a7.Title.Interpreter = 'none';
        a8.XLabel.Interpreter = 'none';
        a8.YLabel.Interpreter = 'none';
        a8.Title.Interpreter = 'none';
        a1.XLabel.String = 'Test Number';
        a1.YLabel.String = 'dt';
        a2.XLabel.String = 'Test Number';
        a2.YLabel.String = 'theta';
        a3.XLabel.String = 'Test Number';
        a3.YLabel.String = 'n_vec(1)';
        a4.XLabel.String = 'Test Number';
        a4.YLabel.String = 'n_vec(2)';
        a5.XLabel.String = 'Test Number';
        a5.YLabel.String = 'n_vec(3)';
        a6.XLabel.String = 'Test Number';
        a6.YLabel.String = 'offset_vec(1)';
        a7.XLabel.String = 'Test Number';
        a7.YLabel.String = 'offset_vec(2)';
        a8.XLabel.String = 'Test Number';
        a8.YLabel.String = 'offset_vec(3)';
        a1.Title.String = 'dt';
        a2.Title.String = 'theta';
        a3.Title.String = 'n_vec(1)';
        a4.Title.String = 'n_vec(2)';
        a5.Title.String = 'n_vec(3)';
        a6.Title.String = 'offset_vec(1)';
        a7.Title.String = 'offset_vec(2)';
        a8.Title.String = 'offset_vec(3)';
        
        waitfor(f)
        
        disp( 'Display Corrections complete.' )
        
    otherwise
        disp( [ '¯\\_(', char(12471), ')_/¯ guess I''ll die...' ] )
        error( 'Tell Marshall his code is jank and how you got here.' )
        
end

end