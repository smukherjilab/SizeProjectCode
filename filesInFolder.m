function fileArray = filesInFolder(path, pattern, withSubfolders)
    fileArray = struct('name','','folder','','date','','bytes',0,'isdir',0,'datenum',0.); % Initialize the file container. We do not know how many files we can find.
    contents = dir(path);
    [numFolders, numImages] = countContents(contents, pattern);
    if numFolders + numImages == 0 % base condition: the folder is empty, only has . and ..
        % Do nothing.
    else
        if numImages > 0
            for i=1:length(contents)
                if not(contents(i).isdir) && isImage(contents(i).name, pattern)
                    fileArray(end+1) = contents(i);
                end
            end
        end
        if withSubfolders % recursion
            for j = 1:length(contents)
                if contents(j).isdir && not(strcmp(contents(j).name,'.')) && not(strcmp(contents(j).name,'..'))
                    fileArray = cat(2,...
                                    fileArray,...
                                    filesInFolder(fullfile(contents(j).folder,...
                                                         contents(j).name),...
                                                  pattern,...
                                                  true));
                end
            end
        end
    end
    fileArray(1)=[]; % delete the empty member created for initialization.
end

function flagImg = isImage(name, pattern)
    if ( contains(name,'.tif','IgnoreCase',true) || contains(name,'.tiff','IgnoreCase',true) || contains(name,'.nd2','IgnoreCase',true) ) & logical( regexp(name,pattern) )
        flagImg = true;
    else
        flagImg = false;
    end
end

function [numFolders, numImages] = countContents(folderMember, pattern)
    numFolders = -2; % There are always '.' and '..'
    numImages = 0;
    for i=1:length(folderMember)
        if folderMember(i).isdir
            numFolders = numFolders + 1;
        elseif isImage(folderMember(i).name, pattern)
            numImages = numImages + 1;
        end
    end
end