function [ret_data] = CRT_smooth_data(return_data)
% CRT_smooth_data Smooths accelerometer & gyro data recorded from Logger.
% Saves all cleaned data to a subfolder called 'Cleaned'

    DataVariables = ["AccX_g_","AccY_g_", "AccZ_g_", "GyrX", "Gyr_y", "Gyr_z", "AccRY", "AccRX", "AccRZ", "AccFZ", "AccFX", "AccFY"];
    [fname,pname] = uigetfile('*');
    data = readtimetable(strcat(pname, fname));

    % Smooth input data
    data = smoothdata(data,"movmean","SmoothingFactor",0.6,"DataVariables",DataVariables);

    cleaned_folder = strcat(pname,'Cleaned/');
    if isfolder(cleaned_folder) == false
        mkdir(cleaned_folder)
    end

    writetimetable(data, strcat(cleaned_folder, fname));
    
    if return_data == true
        ret_data = data;
    else
        ret_data = 0;
    end
end