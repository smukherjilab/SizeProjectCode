# A simple class I defined to simplify my code
# 1 Slice object = 1 image (e.g. 1 z-slice from a stack, or 1 region of a z-slice)

import numpy as np
from PIL import Image
from skimage.transform import resize

class Slice(object):
    def __init__(self, slice):
        self.slice = slice.astype(np.float32)

    # x.slice gets image
    def __getitem__(self):
        return self.slice

    # return width of slice
    def width(self):
        _,w = np.shape(self.slice)
        return w

    # return height of slice
    def height(self):
        h,_ = np.shape(self.slice)
        return h

    # split this slice into tiles of size MxN. tiles are also Slice objects
    def tile(self, M, N):
        im = self.slice
        tiles = [Slice(im[x:x + M, y:y + N]) for x in range(0, im.shape[0], M) for y in range(0, im.shape[1], N)]
        return tiles

    # Z-score data. x.normalize() (no need for assignment!). 
    def normalize(self):
        self.slice = self.slice.astype(np.float32)
        self.slice -= np.mean(self.slice)
        self.slice /= np.std(self.slice)
        return Slice(self.slice)

    # Normalize via dividing by max pixel intensity
    def norm_max(self):
        return Slice(self.slice/np.max(self.slice))

    # reshape Slice to be MxN 
    def reshape(self, M, N):
        return Slice(resize(self.slice, (M, N), mode='constant', preserve_range=True))

    # assign Slice to an Image object (to save as tiff)
    def toimage(self):
        return Image.fromarray(self.slice)
