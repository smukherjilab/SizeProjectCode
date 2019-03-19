function [connStack] = conncompStack(binaryStack)

    [x,y,z] = size(binaryStack);
    
    connStack = zeros(x,y,z);
%     for i=1:2
%         sub(:,:) = 2.*stack(:,:,1) - stack(:,:,2);
%         
%         connStack(:,:,i) = sub==1;
%     end
    connStack(:,:,1) = binaryStack(:,:,1);
    connStack(:,:,z) = binaryStack(:,:,z);
    for i=2:z-1
        sub(:,:) = 3*binaryStack(:,:,i) - binaryStack(:,:,i-1) - binaryStack(:,:,i+1);
        sub(sub<=0) = 3;
        connStack(:,:,i) = sub <3;
    end
end

% 2 - 1 = 1 means its on in both
% 2 - 0 = 2 means its on in slice1
% 0 - 0 = 0 means its off in both

% for comparing above And below:
% 3 -1 -1 =1 means on in all 3
% 3 -1 - 0 = 2 means on in 2
% 3 - 0 - 0 = 3 means on in target