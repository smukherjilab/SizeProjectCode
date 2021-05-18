function mat = rm(volumes,n)

for i=1:size(volumes,1)
    x=volumes(i,:); x = x(x>0);
    if length(x) > n
        volumes(i,:) = NaN;
    end
end
mat = volumes;
end