function [z] = complex_pol2cart(r, theta)
    %% Takes a polar complex number and makes it in cartesian notation.
    % Returns a complex number
    % Note: Theta in degrees!
    
    [x,y] = pol2cart(deg2rad(theta), r);
    z = complex(x, y);
end