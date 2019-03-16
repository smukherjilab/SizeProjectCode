function xyzct = getXYZCT(image5d)
    % get the dimension information 
    % INPUT:  
    %     image5d: a 5-D matrix reshaped so that each dimension means X, 
    %              Y, Z, Channel, and Time, respectively.
    % OUTPUT: 
    %     xyzct:   a vector of length 5, with each element to be the 
    %              number of elements in XYZCT dimensions, respectively.
    xyzct = [size(image5d), ones( 1, 5-length(size(image5d)) )];
end