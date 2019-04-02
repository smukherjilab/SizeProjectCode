% for i = 1:3
%     for j= 1:length(dataCell80{i,1})
%         dataCell80{i,1}{j,2} = length(dataCell80{i,1}{j,1}); % number
%         dataCell80{i,1}{j,3} = mean(dataCell80{i,1}{j,1});   % average size
%         dataCell80{i,1}{j,4} = sum(dataCell80{i,1}{j,1});    % total size
%     end
% end

% SCATTER PLOT FOR TOTAL SIZE 
% sizeVec = size(dataCell80{1,1});
% 
% dataMat80 = zeros(sizeVec(1),3,3);
% for m=1:3
%     for k = 1:sizeVec(1)
%         dataMat80(:,:,m) = cell2mat( dataCell80{m,1}(:,2:4) );
%     end
% end

% SCATTER PLOT FOR AVERAGE SIZE
% scatter3( dataMat75(:,2,1),dataMat75(:,2,2),dataMat75(:,2,3) )
% hold on;
% scatter3( dataMat80(:,2,1),dataMat80(:,2,2),dataMat80(:,2,3) )
% scatter3( dataMat85(:,2,1),dataMat85(:,2,2),dataMat85(:,2,3) )
% scatter3( dataMat90(:,2,1),dataMat90(:,2,2),dataMat90(:,2,3) )
% scatter3( dataMat95(:,2,1),dataMat95(:,2,2),dataMat95(:,2,3) )
% scatter3( dataMat100(:,2,1),dataMat100(:,2,2),dataMat100(:,2,3) )

% SCATTER FOR NUMBER (ER VOLUME)
scatter3( dataMat75(:,2,1),dataMat75(:,1,2),dataMat75(:,1,3) )
hold on;
scatter3( dataMat80(:,2,1),dataMat80(:,1,2),dataMat80(:,1,3) )
scatter3( dataMat85(:,2,1),dataMat85(:,1,2),dataMat85(:,1,3) )
scatter3( dataMat90(:,2,1),dataMat90(:,1,2),dataMat90(:,1,3) )
scatter3( dataMat95(:,2,1),dataMat95(:,1,2),dataMat95(:,1,3) )
scatter3( dataMat100(:,2,1),dataMat100(:,1,2),dataMat100(:,1,3) )

