function [ret_data] = Calculate_roll_heave(return_data)
% Inputs: bool return_data: Set it to true to return th imported data to the workspace.
% Calculates roll and heave per axle.
% Saves all calculated data to a subfolder called 'Calculated'

    [fname,pname] = uigetfile('*.csv');
    if ~any(fname) || ~any(pname)
        errordlg("Calculation aborted!", "Calculate Roll & Heave")
        return 1
    end
    table = importdata(strcat(pname,fname));

    table = array2table(table.data, "VariableNames", table.textdata(1,2:size(table.textdata,2)));

    front_axle = Rotary_to_length("front", table.("DAMPER_LF [deg]"), table.("DAMPER_RF [deg]"));
    rear_axle = Rotary_to_length("rear", table.("DAMPER_LR [deg]"), table.("DAMPER_RR [deg]"));

    table.("Front Roll") = front_axle(:,1);
    table.("Front Heave") = front_axle(:,2);
    table.("Rear Roll") = rear_axle(:,1);
    table.("Rear Heave") = rear_axle(:,2);

    new_folder = strcat(pname,'Calculated/');
    if isfolder(new_folder) == false
        mkdir(new_folder)
    end

    writetable(table, strcat(new_folder, fname));
    
    if return_data == true
        ret_data = table;
    else
        ret_data = 0;
    end
end


function [values] = Rotary_to_length (axle, POT_L, POT_R)
	% Inputs: Columns from logger's data
	% Return values: values(1:) = ROLL, values(2:) = HEAVE
	arraysize = size(POT_L, 1);
	values = zeros(arraysize,2);
	
	for i=1:1:arraysize
		tmp = Rotary_to_length_for_one(POT_L(i), POT_R(i), axle);
		values(i,1) = tmp(1); % ROLL
		values(i,2) = tmp(2); % HEAVE
	end
end

function [DL]=Rotary_to_length_for_one(POT_L, POT_R, axle)
	% Inputs: POT_R, POT_L poy bgazei to rotary
	% potensiometro SE deg!!!
    % Every length unit used is in mm
	% Return variables: DL(1) = Dlroll, DL(2) = Dlheave;
	
    if axle == "front"
	    ycr = 155;
	    zcr = 600;
	    ycl = -155;
	    zcl = 600;
    elseif axle == "rear"
        ycr = 135;
        ycl = -135;
        zcr = 460; 
        zcl = 460;
    end
	
    if axle == "front"
	    Rrheave = 32.88;
	    Rlheave = 32.88;
	    Rrroll = 45.37;
	    Rlroll = 46.09;
    elseif axle == "rear"
        Rrheave = 41;
	    Rlheave = 41.59;
	    Rrroll = 58.46;
	    Rlroll = 107.32;
    end
	
	yrheave = ycr + Rrheave*cosd(POT_R);
	zrheave = zcr + Rrheave*sind(POT_R);
	ylheave = ycl + Rlheave*cosd(POT_L);
	zlheave = zcl + Rlheave*sind(POT_L);
	
    if axle == "front"
	    dfr = rad2deg(2.801952); % Gwnia metaksi roll kai heave sto right rocker
	    dfl = rad2deg(-0.296182); % Gwnia metaksi roll kai heave sto left rocker
    elseif axle == "rear"
        dfr = rad2deg(2.651); % Gwnia metaksi roll kai heave sto right rocker
	    dfl = rad2deg(-0.462); % Gwnia metaksi roll kai heave sto left rocker
    end
	
	yrroll = ycr + Rrroll*cosd(POT_R+dfr);
	zrroll = zcr + Rrroll*sind(POT_R+dfr);
	ylroll = ycl + Rlroll*cosd(POT_L+dfl);
	zlroll = zcl + Rlroll*sind(POT_L+dfl);
	
	Lheave = sqrt( (yrheave-ylheave)^2 + (zrheave - zlheave)^2 ) ;
	c1=0; % H C einai stathera mhdenismou. Otan tha kathete to amaksi tha ginetai ish me Lheave.
	% Apo thn gwnia poy bgazei to potensiometro tha ypologizeis to Lhave. Kai
	% to dl poy theloume einai h afairesh Lheave me thn c.
	Dlheave = Lheave - c1;
	
	Lroll = sqrt( (yrroll - ylroll)^2 + (zrroll - zlroll)^2 ) ;
	c2=0;   % Antistoixa
	Dlroll = Lroll - c2;
	
	DL = [Dlroll, Dlheave];
end
