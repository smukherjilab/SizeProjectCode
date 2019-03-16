


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%
% INSTRUCTIONS
% - Run file
%
%
%
%
%
%
%
%

%======================= USER INPUT ============================

%------- First, ask user for New or Saved Settings ----------- 
list = {'Use New Settings','Use Saved Settings','Cancel'};
[settings_ind, ~] = listdlg('ListString',list);


switch settings_ind     
    case 1         % User wants new settings
        inputs = prompt_input;
        
        if contains(inputs{16,1},"Yes",'IgnoreCase',true)
            filename = inputdlg('Name for saving these inputs: ', 'Saving User Inputs',[1 50]); 
            save(strcat(filename{1},'.mat'),'inputs')
        end
    case 2         % User wants saved settings
        [input_file,input_path] = uigetfile;
        load_inputs = struct2cell(load(fullfile(input_path,input_file)));
        inputs = load_inputs{1};
    otherwise
        error('Choose New or Saved settings')
end

disp('User inputs accepted')

%========================= ANALYSIS ============================

% we will hold file info in this array:
file_stat = [0 0 0 0]; %  ND2,TIF,MULTIPLE ND2, MULTIPLE TIF 
% ------- First, we load the cell/org files ---------
if contains(inputs{1,1},"nd2",'IgnoreCase',true) % files are nd2's
        file_stat(1) = 1;
            
    if contains(inputs{3,1},"yes",'IgnoreCase',true) %multiple nd2's
        file_stat(3) = 1;
        disp('Select nd2s')
        [input_nd2s,path_nd2s] = uigetfile('../*.nd2','MultiSelect','on');
        
        load_nd2s = fullfile(path_nd2s,input_nd2s);
        num_nd2s = length(load_nd2s);  % NUMBER OF ND2s
        nd2s = cell(num_nd2s,1);  % LOCATION OF ND2s
        
        for i=1:num_nd2s     % we store images in a cell array
            this_open = bfopen(fullfile(load_nd2s{1,i}));
            nd2s{i} = this_open{1};
        end
        
   
    elseif contains(inputs{3,1},"no",'IgnoreCase',true) % 1 nd2
        disp('Select nd2')
        [input_nd2,path_nd2] = uigetfile('../*.nd2');
        
        load_nd2 = fullfile(path_nd2,input_nd2);
        nd2 = bfopen(load_nd2);
    else
        error('Invalid input: Input 3')
    end
    
elseif contains(inputs{1,1},"tif",'IgnoreCase',true) % files are tif's
    file_stat(2) = 1;
    if contains(inputs{4,1},"yes",'IgnoreCase',true) %multiple tifs
        file_stat(4) = 1;
        [input_tifs,path_tifs] = uigetfile('../*.tif','MultiSelect','on');
        
        load_tifs = fullfile(path_tifs,input_tifs);
        num_tifs = length(load_tifs); % NUMBER OF TIFs
        tifs = cell(num_tifs,1);  % LOCATION OF TIFs
        
        for i=1:num_tifs   % we store images in a cell array
            tifs{i} = tiffread2(fullfile(load_tifs{1,i}));
        end
        
    elseif contains(inputs{4,1},"no",'IgnoreCase',true) % 1 tif
        [input_tif,path_tif] = uigetfile('../*.tif');
        
        load_tif = fullfile(path_tif,input_tif);
        tif = tiffread2(fullfile(load_tif{1,1}));
    else
        error('Invalid input: input 4')
    end
else
        error('Invalid filetype')
end

disp('User inputs loaded')
% ------------ Second, check if user wants deconvolution ----------------

if contains(inputs{7,1},"yes",'IgnoreCase',true)   % Yes Deconvolution
    disp('Select PSF file')  
    
    [psf_file,psf_path] = uigetfile('../*.tif','Select PSF File');
	load_psf = fullfile(psf_path,psf_file);
	read_psf = tiffread2(load_psf);
    for i=1:length(read_psf)
        psf(:,:,i) = read_psf(i).data;
    end
    
    if contains(inputs{8,1},"yes",'IgnoreCase',true) % Deconvolve Cells
        if file_stat(1) == 1 % file is nd2
            if file_stat(3) == 1 % multiple nd2s
                
                cells = cell(num_nd2s,1);
                orgs = cell(num_nd2s,1);
                this_slice = str2double(inputs{13,1});
                this_chan = str2double(inputs{12,1});
                numChannels = str2double(inputs{5,1});
                
                for i=1:num_nd2s
                    this_psf(:,:) = psf(:,:,25);
                    cells{i,1} = psf_deconv(nd2s{i,1}{numChannels*this_slice-(numChannels-this_chan)},this_psf,inputs{10,1},psf_path);
                    orgs{i,1} = nd2s{i,1}(2:2:end);                  
                end
                
                
            elseif file_stat(3)==0 % 1 nd2
                
                
                if contains(inputs{2},"same",'IgnoreCase',true) 
                    this_slice = str2double(inputs{13,1}); % get info from keyboard
                    this_chan = str2double(inputs{12,1});
                    numChannels = str2double(inputs{5,1});
%                     orgs = nd2{1}(2:2:end);
                    orgs = nd2{1}(2:2:62);
                    cells = nd2{1}{numChannels*this_slice-1,1};
                    cells = psf_deconv(cells,psf,inputs{10,1});
                    
                else
                    disp('Select cells')
                    [input_cells,path_cells] = uigetfile('../*.nd2');
        
                    load_cells = fullfile(path_cells,input_cells);
                    cells = bfopen(load_cells);
                    cells = cells{1}{1};
                    orgs = nd2{1}(:);
                    % FILL ME IN 
                end
            end
            
            
        elseif file_stat(2) == 1  % file is tif
            
            if file_stat(4) == 1   % multiple tifs
                % FILL ME IN 
            elseif file_stat(4) == 0  % 1 tif
                % FILL ME IN 
            end
        else 
            error('file format wrong')
        end
    end
    
    if contains(inputs{9,1},"yes",'IgnoreCase',true) % Deconvolve Orgs
        % FILL ME IN 
    end
    
    disp('Deconvolution Complete')
else    % No Deconvolution
    if file_stat(3) == 1
     disp('correct')
        cells = cell(num_nd2s,1);
                orgs = cell(num_nd2s,1);
                this_slice = str2double(inputs{13,1});
                this_chan = str2double(inputs{12,1});
                numChannels = str2double(inputs{5,1});
                
                for i=1:num_nd2s
                    cells{i,1} = nd2s{i,1}{numChannels*this_slice-(numChannels-this_chan)};
                    orgs{i,1} = nd2s{i,1}(2:2:end);                  
                end
    else
        this_slice = str2double(inputs{13,1});
                    this_chan = str2double(inputs{12,1});
                    numChannels = str2double(inputs{5,1});
%                     orgs = nd2{1}(2:2:end);
                    orgs = nd2{1}(1:2:62);
                    cells = nd2{1}{numChannels*this_slice-(numChannels-this_chan),1};
    end
        
    disp('Deconvolution: No')
end

% ------------- Third, check if user wants segmentation ----------------

if contains(inputs{11,1},"yes",'IgnoreCase',true)  % Yes Segmentation
    
    if file_stat(3) == 1  % multiple nd2s
        binary_cells = cell(num_nd2s,1);
        cell_bounds = cell(num_nd2s,1);
        cell_sizes = cell(num_nd2s,1);
        org_sizes = cell(num_nd2s,1);
        bin_orgg = cell(num_nd2s,1);
        for i=1:num_nd2s %BOOKMARK
            [binary_cells{i,1},cell_bounds{i,1}] = cell_segment(cells{i,1}); 
            [cell_sizes{i,1},org_sizes{i,1},bin_orgg{i,1}] = get_sizes(inputs,cell_bounds{i,1},binary_cells{i,1},orgs{i,1});
        end
        
    elseif file_stat(1) == 1  % 1 nd2
        
        [binary_cells,cell_bounds] = cell_segment(cells);
        [cell_sizes,org_sizes,bin_orgg] = get_sizes(inputs,cell_bounds,binary_cells,orgs);
    end
    
elseif contains(inputs{11,1},"no",'IgnoreCase',true)
    disp('Segmentation: No')
else
    error('Invalid Input: Input 11 is Yes or No')
end

disp('Analysis Complete')




clear psf_path; clear psf_file; clear path_nd2; clear load_psf; clear load_nd2
clear load_inputs; clear list; clear input_path; clear input_nd2; 
clear input_file; clear i; clear file_stat; 


