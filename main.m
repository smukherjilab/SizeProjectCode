% require bfopen.m

filePath = 'D:\OneDrive\Documents\RESEARCH\AI_IMAGE_PROCESS\matlab\denoised\dnCNN_Try5_0hour_Leu95_445nm514nm_unmixed.tiff';
imgCells = fileToMatrices(filePath);

% %%%% A simple trial that returns all organelles in an image
% volumesCell = cell(length(imgCells),1);
% for i=1:length(imgCells)
%     volumesCell{i} = organelleAnalysis2D(imgCells{i},5,500);
% end

% %%%% as a temporary workaround, we use a cell same as 'test190224.mat'
% %%%% and just feed getSizes everything it needs.
