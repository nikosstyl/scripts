function [] = CRT_smooth_data()
% CRT_smooth_data: Smooths accelerometer & gyro data recorded from Logger.
% Also, calculates heave and roll on each axle.
% Saves all cleaned data to a subfolder called 'Cleaned'.

    [fname,pname] = uigetfile('*.csv');
    if ~any(fname) || ~any(pname)
        errordlg("Calculation aborted!", "CRT Data Smoother")
        return
    end
    table = importdata(strcat(pname, fname));
    table = array2table(table.data, "VariableNames", table.textdata(1,2:size(table.textdata,2)));

    front_axle = Rotary_to_length("front", table.("DAMPER_LF [deg]"), table.("DAMPER_RF [deg]"));
    rear_axle = Rotary_to_length("rear", table.("DAMPER_LR [deg]"), table.("DAMPER_RR [deg]"));
    table.("Front Roll") = front_axle(:,1);
    table.("Front Heave") = front_axle(:,2);
    table.("Rear Roll") = rear_axle(:,1);
    table.("Rear Heave") = rear_axle(:,2);

    % Smooth input data
    DataVariables.movement = ["Acc y","Acc x","Acc z","Gyr x","Gyr_y","Gyr_z",...
        "Acc R y","Acc R x","Acc R z","Acc F z","Acc F x","Acc F y",];
    DataVariables.dampers  = ["DAMPER_LF [deg]", "DAMPER_RF [deg]",...
        "DAMPER_LR [deg]", "DAMPER_RR [deg]", "Front Roll", ...
        "Front Heave", "Rear Roll", "Rear Heave"];

    % Smooth acceleration data with a bigger smoothing factor.
    table = smoothdata(table,"movmean","SmoothingFactor",0.6,"DataVariables",DataVariables.movement);
    % Smooth damper data with a smaller smoothing factor.
    table = smoothdata(table,"movmean","SmoothingFactor",0.35,"DataVariables",DataVariables.dampers);

    cleaned_folder = strcat(pname,'Cleaned/');
    if isfolder(cleaned_folder) == false
        mkdir(cleaned_folder)
    end

    writetable(table, strcat(cleaned_folder, fname));
    
end
