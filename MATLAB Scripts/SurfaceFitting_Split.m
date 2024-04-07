%% Surface Fitting for Coefficient of Drag (Z-axis) with Pitch Angles (X-axis) and Altitude (Y-axis)

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
    pitch      = data(1, 2:end);
    altitude   = data(2:end, 1);
    coeff_drag = data(2:end, 2:end);
    

    % Initialize arrays to store fit objects, goodness of fit, and outputs
    fit_objects   = cell(1, num_regions);
    gof_values    = cell(1, num_regions);
    output_values = cell(1, num_regions);

    % Initialize arrays to store axis handles
    all_axes = gobjects(num_regions, 2);  


    % Loop through pitch regions for surface fit (equations and plots)
    for i = 1:num_regions

        % Create region names
        region_name = sprintf('Region %d', i);

        % Find indices for the current pitch region
        indices = find(pitch >= pitch_ranges(i, 1) & pitch <= pitch_ranges(i, 2));

        % Extract data for the current pitch region
        pitch_region      = pitch(indices);
        altitude_region   = altitude;
        coeff_drag_region = coeff_drag(:, indices);
        
        % Define fit type
        if num_regions == 5
            if pitch_ranges(i, 1) >= P3 && pitch_ranges(i, 2) <= P4
                fit_type = 'poly23';
            elseif (pitch_ranges(i, 1) >= P2 && pitch_ranges(i, 2) <= P3) || (pitch_ranges(i, 1) >= P4 && pitch_ranges(i, 2) <= P5)
                fit_type = 'poly33';
            else 
                fit_type = 'poly33';
            end
        elseif num_regions == 3
            if pitch_ranges(i, 1) >= P2 && pitch_ranges(i, 2) <= P3
                fit_type = 'poly23';
            elseif (pitch_ranges(i, 1) >= P1 && pitch_ranges(i, 2) <= P2) || (pitch_ranges(i, 1) >= P3 && pitch_ranges(i, 2) <= P4)
                fit_type = 'poly33';
            end
        end

        % Perform surface fit
        [pitch_region_grid, altitude_region_grid] = meshgrid(pitch_region, altitude_region);
        [fit_objects{i}, gof_values{i}, output_values{i}] = fit([pitch_region_grid(:), altitude_region_grid(:)], coeff_drag_region(:), fit_type);

        % Determine the surface fit equation
        f     = string(formula(fit_objects{i}));
        names = coeffnames(fit_objects{i});
        vals  = coeffvalues(fit_objects{i});
        for k = 1:length(names)
            f = strrep(f,string(names(k)),string(vals(k)));
        end
        fprintf('Equation = %s\n', f)
        disp(fit_objects{i})


        % Create figure for the current data file and data region
        figure('Position', figPosition)

        % Subplot for data points only
        ax_data = subplot(1, 2, 1);
        scatter3(pitch_region_grid(:), altitude_region_grid(:), coeff_drag_region(:), 'b.', 'SizeData', 150);
        xlabel('Pitch Angle (Deg)');
        ylabel('Altitude (km)');
        zlabel('Coefficient of Drag');
        title(['Data Points  (Pitch ', region_name, ')']);
        grid on;
        box on;
        rotate3d(ax_data, 'on');

        % Subplot for surface fit
        ax_fit = subplot(1, 2, 2);
        plot(fit_objects{i}, [pitch_region_grid(:), altitude_region_grid(:)], coeff_drag_region(:));
        xlabel('Pitch Angle (Deg)');
        ylabel('Altitude (km)');
        zlabel('Coefficient of Drag');
        title({['Surface Fit with Data Points (Pitch ', region_name, ')']; ...
               ['RMSE = ', num2str(gof_values{i}.rmse), '       |       ', 'R-square = ', num2str(gof_values{i}.rsquare)]});
        grid on;
        box on;
        rotate3d on;

    
        % Store axis handles
        all_axes(i, 1) = ax_data;
        all_axes(i, 2) = ax_fit;


        % Adjust figure properties
        if file_idx == 1
            sgtitle({'\bf\fontsize{16} Satellite with FIXED Panels'; ['\bf\fontsize{12} Equation = ', num2str(f)]; '    '});
        elseif file_idx == 2 
            sgtitle({'\bf\fontsize{16} Satellite with ROTATING Panels'; ['\bf\fontsize{12} Equation = ', num2str(f)]; '    '});
        end

        % Link axes between subplots within each figure
        linkaxes([ax_data, ax_fit], 'xyz');
       
    end

    % Link rotation for all subplots across all figures
    hlink = linkprop(all_axes(:), 'View');

    % Link yz-axes among figures 1, 2, 4, and 5
    linkaxes(all_axes(ismember(1:size(all_axes,1), [1, 2, 4, 5]), :), 'yz');

end
