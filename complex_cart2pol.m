function [ret] = complex_cart2pol(z)
    %% Takes a cartesian complex number and makes it in polar notation.
    % Returns r (ans(1)) and theta (ans(2))
    % Note: Theta in degrees!

    [ret(2),ret(1)] = cart2pol(real(z), imag(z));
    ret(2) = rad2deg(ret(2));
end