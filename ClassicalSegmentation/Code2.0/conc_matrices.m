function matrix = conc_matrices(varargin)

    dims = zeros([length(varargin),2]);
    
    for i=1:length(varargin)
        dims(i,1) = size(varargin{i},1);
        dims(i,2) = size(varargin{i},2);
    end
    
    matrix = nan([sum(dims(:,1)), max(dims(:,2))]);
    
    m = 1; 
    for i=1:length(varargin)
        matrix(m:m+dims(i,1)-1,1:dims(i,2)) = varargin{i};
        m = m + dims(i,1);
    end
%     
%     volumes = matrix; [M,N] = size(volumes);
%     [~,col1] = sort(~isnan(volumes),2,'descend'); row1 = repmat(1:M,N,1)';
%     restructured_indices = sub2ind(size(volumes),row1(:),col1(:));
%     volumes = reshape(volumes(restructured_indices),M,N);
%     
%     matrix = volumes;
end
