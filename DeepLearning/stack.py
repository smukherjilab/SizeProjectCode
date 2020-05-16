# A class I defined to help simplify my code. 
# 1 ZStack object holds 1 tiff stack. 

import numpy as np
from PIL import Image
from slice import Slice

# remember 0-indexing!

class ZStack(object):
    
    # INPUTS: 
    #        path -- path to the tiff stack (or 2D)
    #        zrange -- z-slices that you want to process. If tiff is 2d, write (0,0)
    
    def __init__(self, path, zrange=(1,31)):
        self.path = path
        self.zrange = zrange
        
        data = Image.open(path)
        ims = []
        for i in range(zrange[0]-1, zrange[1]):   # -1 to adjust for zero-indexing
            data.seek(i)
            ims.append(np.array(data))

        self.images = ims
        self.depth = len(self.images)
        self.index = 0

    # [] indexing gives access to zslices; remember, slice1 starts at 0!
    def __getitem__(self, idx):
        image = self.images[idx]
        image = image.astype(np.float32)
        return image

    def __iter__(self):
        return self

    def __next__(self):
        try:
            result = self.images[self.index]
        except IndexError:
            raise StopIteration
        self.index += 1
        return result

    # length of ZStack is its depth (ie, # of images)
    def __len__(self):
        return self.depth
