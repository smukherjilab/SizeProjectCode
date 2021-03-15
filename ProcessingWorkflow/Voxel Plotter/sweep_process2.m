




%%
function data_dist = sweep_process2(T_range, S_range, MIN_ORG_SIZE_range,...
    PATH_ORGS, PATH_ORGS_RAW,PATH_CELLS, Z, CC, STREL_SIZE, save_img,varargin)
    
    num_iters = length(T_range)*length(S_range)*length(MIN_ORG_SIZE_range)*length(STREL_SIZE);
    
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
                for SE=1:length(STREL_SIZE)
                    n = n + 1;
                    this_data_set = process2(PATH_ORGS,PATH_ORGS_RAW,PATH_CELLS,... 
                        Z, T_range(T), S_range(S), CC, MIN_ORG_SIZE_range(M),STREL_SIZE(SE),save_img,varargin);

                    this_data_set.T = T_range(T);
                    this_data_set.S = S_range(S);
                    this_data_set.M = MIN_ORG_SIZE_range(M);
                    this_data_set.SE = STREL_SIZE(SE);
                    data_dist.data{n} = this_data_set;
                    disp(['Iter ' num2str(n) ' of ' num2str(num_iters)])
                end
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