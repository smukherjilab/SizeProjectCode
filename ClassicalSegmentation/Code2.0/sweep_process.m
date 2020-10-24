

%
% this script returns data over distribution of image-processing params
%

%{

Motivation: features can be sensitive to processing settings; this code
aims to ensure that an observed feature is real, instead of an artifact of
processing

Note: this code is lazy, in many ways, but particularly in that it reads
the images for every parameter set. I did this because I rather have 1 code
to share than 2. 

P.S. look in "process.m" for documentation on parameters/analysis

%}

%% INPUTS:
%{
- T_range: thresholds to try. 
           eg: T_range = 0.1:0.1:0.4

- S_range: sigmas to try.
           eg: S_range = 0.5:0.5:1.5

- MIN_ORG_SIZE_range: ranges of minimum organelle sizes to try
           eg: MIN_ORG_SIZE_range = 10:10:40

- PATH_ORGS: path to input organelle images (tifs)
           eg: PATH_ORGS = '/Users/asakalish/Desktop/OrgsStack.tif'

- PATH_CELLS: path to input cell images (tif or mat)
           eg: PATH_ORGS = '/Users/asakalish/Desktop/OrgsStack.tif'
Note: expect 2D input (ie, not a stack of cell images)

- Z: which z-slices of stack to analyze
           eg: Z = [5 25]
            or Z = [1 1]

- CC: connected components for clustering of pixels (more details in
"process.m"

- varargin (optional inputs)
    - 'min_cell_size' default = 1000
    - 'max_org_size' default = 10000;

Example of using varargin:

data = process(PATH_ORGS, PATH_CELLS, Z, THRESHOLD, SIGMA, CC,...
MIN_ORG_SIZE, 'min_cell_size', 500, 'max_org_size', 5000); 

arguments in '' are case-SENSITIVE

%}

%% OUTPUTS:
%{

data_dist: a struct that holds all of the datasets & the 
%}



%%
function data_dist = sweep_process(T_range, S_range, MIN_ORG_SIZE_range,...
    PATH_ORGS, PATH_CELLS, Z, CC, varargin)
    
    num_iters = length(T_range)*length(S_range)*length(MIN_ORG_SIZE_range);
    
    data_dist.data = cell([num_iters, 1]);
   
    if contains(class(PATH_ORGS),{'char','string'}) % if we need to load the image
        sweep = 'false';
    else % if we're plugging in image
        sweep = 'true';
    end
    varargin{end+1} = 'sweep';
    varargin{end+1} = sweep;
        
    
    n = 0;
    for T=1:length(T_range)
        for S=1:length(S_range)
            for M=1:length(MIN_ORG_SIZE_range)
                
                n = n + 1;
                this_data_set = process(PATH_ORGS,PATH_CELLS,... 
                    Z, T_range(T), S_range(S), CC, MIN_ORG_SIZE_range(M),varargin);
                
                this_data_set.T = T_range(T);
                this_data_set.S = S_range(S);
                this_data_set.M = MIN_ORG_SIZE_range(M);
                
                data_dist.data{n} = this_data_set;
                disp(['Iter ' num2str(n) ' of ' num2str(num_iters)])
            end
        end
    end
    
    data_dist.T_range = T_range;
    data_dist.S_range = S_range;
    data_dist.MIN_ORG_SIZE_range = MIN_ORG_SIZE_range;
    data_dist.PATH_ORGS = PATH_ORGS;
    data_dist.PATH_CELLS = PATH_CELLS;
    data_dist.Z = Z;
    data_dist.CC = CC;
    data_dist.varargin = varargin;
end