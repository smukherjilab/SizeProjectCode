%%%% A script that analyzes a type of organelle in the cells %%%%

%%%% March 13, 2019: four channels: ER, lipid droplets, mitochondria, cell boundaries

pathIn = 'D:\Documents\Files\denoised\Try11_Leucine75100';
files = filesInFolder(pathIn,'.tiff',false);
dataCell = cell(3,1);
i = 5;
imageCell = fileToMatrices( fullfile(files(i).folder, files(i).name) ); % should be 4*1 cell
cellBoundMatrix = imageCell{4};
cellLabelMatrix = objBinarize(cellBoundMatrix,15,30,'background');
cellLabelMatrix = labelmatrix( bwconncomp(cellLabelMatrix) );
for j =1:3
    dataCell{j} = organelleInCells(imageCell{j},cellLabelMatrix);
end

for k = 1:length(dataCell{1,1})
    dataCell{1,1}{k} = sum(dataCell{1,1}{k});
end