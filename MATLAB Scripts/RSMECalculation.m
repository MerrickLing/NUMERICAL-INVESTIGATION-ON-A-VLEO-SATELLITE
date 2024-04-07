%% RSME Calculation of the Entire Field

close all;
clear all;
clc;

% Get the screen size
screenSize = get(0, 'ScreenSize');

% Calculate the position and size for the figure
figWidth = screenSize(3) / 2;  % Half of the screen width
figHeight = screenSize(4) / 2; % Half of the screen height

% Adjust the position to the top right quadrant with a downward shift
figPosition = [screenSize(3)/2, screenSize(4)/2 - figHeight/2, figWidth, figHeight];


% Defining the filenames of the data files
data_files = {'Satellite_FixedPanels_Cd_Data.txt', 'Satellite_RotatingPanels_Cd_Data.txt'};


% Defining the pitch regions and ranges
num_regions = 5;

if num_regions == 5
    % Define pitch interval breaks selected based on relatively constant regions
    P1 = -90 ;
    P2 = -20 ;
    P3 = -5  ;
    P4 =  5  ;
    P5 =  20 ;
    P6 =  90 ;

    % Define pitch regions for analysis
    pitch_ranges = [P1, P2; P2, P3; P3, P4; P4, P5; P5, P6];

elseif num_regions == 3
    % Define pitch interval breaks selected based on relatively constant regions
    P1 = -90 ;
    P2 = -5  ;
    P3 =  5  ;
    P4 =  90 ;

    % Define pitch regions for analysis
    pitch_ranges = [P1, P2; P2, P3; P3, P4];

end


% Loop over each data file
for file_idx = 1:numel(data_files)
    if file_idx == 1
        fprintf('\n\n\n\n------Satellite with FIXED Panels------\n\n');
    elseif file_idx == 2 
        fprintf('\n\n\n\n------Satellite with ROTATING Panels------\n\n');
    end

    % Load data from file
    data = readmatrix( data_files{file_idx} );

    % Extract altitude, pitch, and coefficient of drag data
    pitch    = data(1, 2:end);
    altitude = data(2:end, 1);
    cd_original = data(2:end, 2:end)
        
    % Initialize matrix to store calculated coefficient of drag values
    cd_calculated = zeros(size(cd_original));

    % Create figure for the current data file and data region
    figure('Position', figPosition)

    % Define polynomial equations for each region
    if file_idx == 1
        % Fixed Panels (Original)
        if num_regions == 5
            equations = {@(x,y) (2.0154 + 0.001178.*x + 0.00051258.*y + 3.6151e-05.*x.^2 + -8.7829e-07.*x.*y + -1.4424e-06.*y.^2 + 2.0506e-07.*x.^3 + -1.7234e-08.*x.^2.*y + -1.31e-08.*x.*y.^2 + 2.254e-09.*y.^3),...
                         @(x,y) (2.1637 + 0.084126.*x + 0.0035953.*y + 0.0076318.*x.^2 + 0.00024868.*x.*y + -4.9498e-06.*y.^2 + 0.00019388.*x.^3 + 5.4827e-06.*x.^2.*y + -1.2219e-07.*x.*y.^2 + 4.1113e-09.*y.^3),...
                         @(x,y) (2.647 + 0.0018265.*x + 0.0095079.*y + -0.049269.*x.^2 + 4.4563e-06.*x.*y + -1.9707e-05.*y.^2 + -7.9434e-05.*x.^2.*y + -2.673e-08.*x.*y.^2 + 1.8586e-08.*y.^3),...
                         @(x,y) (2.295 + -0.09462.*x + 0.0028119.*y + 0.0080744.*x.^2 + -0.0002318.*x.*y + -2.7391e-06.*y.^2 + -0.00020452.*x.^3 + 5.9214e-06.*x.^2.*y + 8.8481e-08.*x.*y.^2 + 1.8565e-09.*y.^3),...
                         @(x,y) (2.0069 + -0.00076481.*x + 0.00054999.*y + 2.9335e-05.*x.^2 + 5.2195e-07.*x.*y + -1.3788e-06.*y.^2 + -1.6473e-07.*x.^3 + -2.5639e-08.*x.^2.*y + 1.5737e-08.*x.*y.^2 + 1.8705e-09.*y.^3)};
        elseif num_regions == 3
            equations = {@(x,y) (2.0992 + 0.013364.*x + 0.001323.*y + 0.00034795.*x.^2 + 2.0771e-05.*x.*y + -2.2627e-06.*y.^2 + 2.3435e-06.*x.^3 + 1.3522e-07.*x.^2.*y + -1.9691e-08.*x.*y.^2 + 2.7023e-09.*y.^3),...
                         @(x,y) (2.647 + 0.0018265.*x + 0.0095079.*y + -0.049269.*x.^2 + 4.4563e-06.*x.*y + -1.9707e-05.*y.^2 + -7.9434e-05.*x.^2.*y + -2.673e-08.*x.*y.^2 + 1.8586e-08.*y.^3),...
                         @(x,y) (2.1328 + -0.014234.*x + 0.0011256.*y + 0.00035595.*x.^2 + -1.7486e-05.*x.*y + -1.7315e-06.*y.^2 + -2.354e-06.*x.^3 + 1.0287e-07.*x.^2.*y + 2.1048e-08.*x.*y.^2 + 1.8893e-09.*y.^3)};
        end
            
    elseif file_idx == 2 
        % Rotating Panels
        if num_regions == 5
            equations = {@(x,y) (2.0498 + 0.0039155.*x + 0.0011522.*y + 7.1702e-05.*x.^2 + -1.6988e-06.*x.*y + -3.5479e-06.*y.^2 + 3.7969e-07.*x.^3 + -3.4152e-08.*x.^2.*y + -1.3766e-08.*x.*y.^2 + 4.53e-09.*y.^3),...
                         @(x,y) (2.202 + 0.098636.*x + 0.0047588.*y + 0.0084267.*x.^2 + 0.00023956.*x.*y + -8.7602e-06.*y.^2 + 0.00020863.*x.^3 + 4.9199e-06.*x.^2.*y + -1.3025e-07.*x.*y.^2 + 8.1251e-09.*y.^3),...
                         @(x,y) (2.5923 + -0.00024171.*x + 0.010133.*y + -0.046752.*x.^2 + 5.567e-06.*x.*y + -2.1924e-05.*y.^2 + -7.2934e-05.*x.^2.*y + -5.6302e-09.*x.*y.^2 + 2.1053e-08.*y.^3),...
                         @(x,y) (2.3068 + -0.10741.*x + 0.0039833.*y + 0.0089939.*x.^2 + -0.00024049.*x.*y + -5.9729e-06.*y.^2 + -0.00021914.*x.^3 + 4.9476e-06.*x.^2.*y + 1.2306e-07.*x.*y.^2 + 5.1709e-09.*y.^3),...
                         @(x,y) (2.0465 + -0.0022796.*x + 0.00096743.*y + 3.5876e-05.*x.^2 + 2.6137e-06.*x.*y + -2.993e-06.*y.^2 + -1.2183e-07.*x.^3 + -6.6393e-08.*x.^2.*y + 1.789e-08.*x.*y.^2 + 3.7736e-09.*y.^3)};
        elseif num_regions == 3
            equations = {@(x,y) (2.1277 + 0.017095.*x + 0.0021701.*y + 0.00041161.*x.^2 + 2.3045e-05.*x.*y + -4.7812e-06.*y.^2 + 2.7152e-06.*x.^3 + 1.3875e-07.*x.^2.*y + -2.1294e-08.*x.*y.^2 + 5.369e-09.*y.^3),...
                         @(x,y) (2.5923 + -0.00024171.*x + 0.010133.*y + -0.046752.*x.^2 + 5.567e-06.*x.*y + -2.1924e-05.*y.^2 + -7.2934e-05.*x.^2.*y + -5.6302e-09.*x.*y.^2 + 2.1053e-08.*y.^3),...
                         @(x,y) (2.1559 + -0.016881.*x + 0.0018358.*y + 0.00040965.*x.^2 + -2.3418e-05.*x.*y + -3.6069e-06.*y.^2 + -2.6957e-06.*x.^3 + 1.2502e-07.*x.^2.*y + 2.3958e-08.*x.*y.^2 + 4.0282e-09.*y.^3)};
        end

    end

    
    
    % Calculate coefficient of drag for each region
    if num_regions == 5
        region_sequence = [1, 5, 2, 4, 3];
    elseif num_regions == 3
        region_sequence = [1, 3, 2];
    end

    for region = region_sequence
        % Extract pitch range for the current region
        pitch_range = pitch >= pitch_ranges(region, 1) & pitch <= pitch_ranges(region, 2);
        
        % Create meshgrid of pitch and altitude values for the current region
        [X_region, Y_region] = meshgrid(pitch(pitch_range), altitude);
        
        % Extract coefficients for the current region
        equation = equations{region};
        
        % Calculate coefficient of drag using the polynomial equation for the current region
        cd_region = equation(X_region, Y_region);
        
        % Store calculated coefficient of drag values in the appropriate region
        cd_calculated(:, pitch_range) = cd_region;
    
    end

    % Display the calculated cd values
    cd_calculated

    % Calculate RMSE for the entire field
    rmse = sqrt(mean((cd_original(:) - cd_calculated(:)).^2));
    average_value = mean(cd_original, 'all')
    rmse_percentage = (rmse / average_value) * 100;
    
    % Display RMSE
    disp(['RMSE for the entire field: ', num2str(rmse)])
    disp(['RMSE for the entire field (% of mean original Cd): ', num2str(rmse_percentage)])

    % Create meshgrid of pitch and altitude values for the whole field
    [X_field, Y_field] = meshgrid(pitch, altitude);

    % Plotting of Original Values with Calculated Values
    hold on;
    scatter3(X_field(:), Y_field(:), cd_original(:),'filled', 'MarkerFaceColor', [0 0 1], 'SizeData', 50, 'DisplayName', 'Original Data');
    scatter3(X_field(:), Y_field(:), cd_calculated(:), 'filled', 'MarkerFaceColor', [0.6350 0.0780 0.1840],'SizeData', 50, 'DisplayName', 'Calculated Data');
    xlabel('Pitch Angle (Deg)');
    ylabel('Altitude (km)');
    zlabel('Coefficient of Drag');
    if file_idx == 1
        title({'\bf\fontsize{16} Satellite with FIXED Panels'; ['\bf\fontsize{12} RMSE = ', num2str(rmse)]; ['\bf\fontsize{12} RMSE (% of mean original Cd) = ', num2str(rmse_percentage)]; '    '});
    elseif file_idx == 2 
        title({'\bf\fontsize{16} Satellite with ROTATING Panels'; ['\bf\fontsize{12} RMSE = ', num2str(rmse)]; ['\bf\fontsize{12} RMSE (% of mean original Cd) = ', num2str(rmse_percentage)]; '    '});
    end

    % Add legend
    legend('Location', 'best');

    grid on;
    box on;
    rotate3d on;
    view(3);
    hold off;

end
