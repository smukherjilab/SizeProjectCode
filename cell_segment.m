function [binary_field,cell_bounds] = cell_segment(cell_field)

    binary_field = b_fill_water(cell_field);
 
    cell_bounds = bwboundaries(binary_field,4,'noholes');
    
end