import numpy as np
from PIL import Image
from slice import Slice
# i wrote this class to address frustrations while processing data for deep learning
# before, i would:
# load 3D tiff into imagej -> split each z into 64 tiles, 1 z at a time
# -> save the tiles on my desktop -> read into pycharm -> perform inference
# -> save tiles to desktop

# this class will hopefully facilitate bringing all of those processes into 1 script in python
# and eventually, should make it easier to work with multiple zstacks at a time
# (whilst not losing my intuition with the code)

# just remember 0-indexing!

class ZStack(object):
    def __init__(self, path, zrange=(0,30)):

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

    # method to write ZStack to 3D tiff
    # def save(self):


