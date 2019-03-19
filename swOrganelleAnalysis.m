%%%% A script that analyzes a type of organelle in the cells %%%%

%%%% March 13, 2019: four channels: ER, lipid droplets, mitochondria, cell boundaries

pathIn = 'D:\Documents\Files\denoised\Try11_Leucine75100';
files = filesInFolder(pathIn,'.tiff',false);
dataCell = cell(3,1);
i = 6;
imageCell = fileToMatrices( fullfile(files(i).folder, files(i).name) ); % should be 4*1 cell
cellBoundMatrix = imageCell{4};
[binary_cells,cell_bounds] = cellSegment(cellBoundMatrix);
cell_sizes = cell(3,1);
volumes = cell(3,1);
binary_orgs = cell(3,1);
for j =1:3
    organelleMatrix = imageCell{j};
    [cell_sizes{j},volumes{j},binary_orgs{j}] = getSizes2D(cell_bounds,binary_cells,{organelleMatrix},'globular');
end