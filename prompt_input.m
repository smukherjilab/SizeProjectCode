function [inputs] = prompt_input(varargin)
    
if isempty(varargin)
    prompt = {'Filetype (tif or nd2): ', 'If organelles and cells appear in same file, enter Same: ',...
        'Multiple nd2 files (Yes, No, or NaN): ','Multiple tif files (Yes, No, or NaN): ',...
        'Number of Channels: ', 'Number of z-slices: ',...
        'Deconvolution (If no, leave next 5 fields blank): ',...
        'Deconvolve Cells (Yes or No): ', 'Deconvolve Organelles (Yes or No): ',...
        'Algorithm: ', 'Segment Cells (Yes or No): ','Which channel has cells (if applicable): ',...
        'Which z-slice has cells (if applicable)','Z-slices framerange (enter All or use format x-y): ',...
        'Organelle Shape (globular, tubular, or other): ', 'Save input settings (Yes or No): '};

        title = 'Inputs';
        dims = [1 65];

        inputs = inputdlg(prompt,title,dims);
        inputs{1,2} = 'Filetype';
        inputs{2,2} = 'Orgs/Cells in same file?';
        inputs{3,2} = 'Multiple nd2s?';
        inputs{4,2} = 'Multiple tifs?';
        inputs{5,2} = 'Number of Channels';
        inputs{6,2} = 'Number of z-slices';
        inputs{7,2} = 'Deconvolution?';
        inputs{8,2} = 'Deconvolve Cells?';
        inputs{9,2} = 'Deconvolve Organelles?';
        inputs{10,2} = 'Deconvolution Algorithm';
        inputs{11,2} = 'Segment Cells?';
        inputs{12,2} = 'Channel w/ cells (if applicable)';
        inputs{13,2} = 'Z-slice w/ cells (if applicable)';
        inputs{14,2} = 'Z-slices framerange';
        inputs{15,2} = 'Organelle Shape';
        inputs{16,2} = 'Save input settings?';
else
    inputs = varargin{1};   
end


end

