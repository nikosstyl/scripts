function [ret_data] = Calculate_roll_heave(return_data)
% Inputs: bool return_data: Set it to true to return th imported data to the workspace.
% Calculates roll and heave per axle.
% Saves all calculated data to a subfolder called 'Calculated'

    [fname,pname] = uigetfile('*');
    data = readtable(strcat(pname, fname));
    
    front_axle = Rotary_to_length(data.DAMPER_LF_deg_, data.DAMPER_RF_deg_);
    rear_axle = Rotary_to_length(data.DAMPER_LR_deg_, data.DAMPER_RR_deg_);

    Front_Roll = front_axle(:,1);
    Front_Heave = front_axle(:,2);
    Rear_Roll = rear_axle(:,1);
    Rear_Heave = rear_axle(:,2);

    data.Front_Roll = Front_Roll;
    data.Front_Heave = Front_Heave;
    data.Rear_Roll = Rear_Roll;
    data.Rear_Heave = Rear_Heave;

    new_folder = strcat(pname,'Calculated/');
    if isfolder(new_folder) == false
        mkdir(new_folder)
    end

    writetable(data, strcat(new_folder, fname));
    
    if return_data == true
        ret_data = data;
    else
        ret_data = 0;
    end
end


function [axle] = Rotary_to_length (POT_L, POT_R)
	% Inputs: Columns from logger's data
	% Return values: axle(1:) = ROLL, axle(2:) = HEAVE
	arraysize = size(POT_L, 1);
	axle = zeros(arraysize,2);
	
	for i=1:1:arraysize
		tmp = Rotary_to_length_for_one(POT_L(i), POT_R(i));
		axle(i,1) = tmp(1); % ROLL
		axle(i,2) = tmp(2); % HEAVE
	end
end

function [DL]=Rotary_to_length_for_one(POT_L, POT_R)
	% Inputs: POT_R, POT_L poy bgazei to rotary
	% potensiometro SE deg!!!
	% Return variables: DL(1) = Dlroll, DL(2) = Dlheave;
	
	ycr = 155;
	zcr = 600;
	ycl = -155;
	zcl = 600;
	
	Rrheave = 32.88;
	Rlheave = 32.88;
	Rrroll = 45.37;
	Rlroll = 46.09;
	
	yrheave = ycr + Rrheave*cosd(POT_R);
	zrheave = zcr + Rrheave*sind(POT_R);
	ylheave = ycl + Rlheave*cosd(POT_L);
	zlheave = zcl + Rlheave*sind(POT_L);
	
	dfr = rad2deg(2.801952); % Gwnia metaksi roll kai heave sto right rocker
	dfl = rad2deg(-0.296182); % Gwnia metaksi roll kai heave sto left rocker
	
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
