function [ret_data] = CRT_smooth_data(return_data)
% CRT_smooth_data Smooths accelerometer & gyro data recorded from Logger.
% Saves all cleaned data to a subfolder called 'Cleaned'

    [fname,pname] = uigetfile('*');
    table = importdata(strcat(pname, fname));
    table = array2table(table.data, "VariableNames", table.textdata(1,2:size(table.textdata,2)));

    % Smooth input data
    DataVariables = ["Acc y","Acc x","Acc z","Gyr x","Gyr_y","Gyr_z","Acc R y","Acc R x","Acc R z","Acc F z","Acc F x","Acc F y"];
    table = smoothdata(table,"movmean","SmoothingFactor",0.6,"DataVariables",DataVariables);

    cleaned_folder = strcat(pname,'Cleaned/');
    if isfolder(cleaned_folder) == false
        mkdir(cleaned_folder)
    end

    writetable(table, strcat(cleaned_folder, fname));
    
    if return_data == true
        ret_data = data;
    else
        ret_data = 0;
    end
end
