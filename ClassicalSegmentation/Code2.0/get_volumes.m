
% support for allometry_analysis.m

function all_dists = get_volumes(varargin)

    % dist.data is a nx1 cell array, 
    % for each i = 1,...,N 
    % we want to merge dist1.data{i}, dist2.data{i}, ..., distM.data{i}
    % where M = length(varargin);
    
    M = length(varargin);
    N = length(varargin{1}.data);
    all_dists = cell([N, 1]);
    
    for i=1:N  % step thru parameter sets
        for j=1:M
            all_dists{i} = conc_matrices(all_dists{i}, varargin{j}.data{i}.volumes);
%             conc_matrices(varargin{j}.data{i}.volumes,varargin{j+1}.data{i}.volumes);
        end
    end
end