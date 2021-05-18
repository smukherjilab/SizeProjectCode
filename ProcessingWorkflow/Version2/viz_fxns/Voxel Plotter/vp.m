function [vol_handle]=vp(VoxelMat,Vox_Size,varargin)
%detect the external voxels and faces
if isempty(varargin)
    figure();
else
end
vol_handle=0;
if nargin==1
Vox_Size=1;
end
    FV=FindExternalVoxels(VoxelMat,Vox_Size);
%plot only external faces of external voxels
cla;
if size(FV.vertices,1)==0
    cla;
else
vol_handle=patch(FV,'FaceColor',[.4 .4 .4]);
% vol_handle = FV;
%use patchslim here for better results
end
grid on;

[X,Y,Z] = size(VoxelMat);

xlim([0 X]); ylim([0 Y]); zlim([0 Z]);
end

