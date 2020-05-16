import os
import time
import numpy as np
import torch
import matplotlib
matplotlib.use("TkAgg")
os.environ['KMP_DUPLICATE_LIB_OK'] = 'True'
import json
import sys
from torch.utils.data import DataLoader
from ast import literal_eval
from Model import MyModel
from Dataclass import FormsDataset
from Stack import ZStack
from Slice import Slice

start_time = time.time()


# stitch tiles back into 1 slice, assuming tiles are no longer Slices
def stitch(tiles, slice_shape=(2044, 2048), IMG_WIDTH=256, IMG_HEIGHT=256):
    slice = np.zeros(slice_shape)
    # M, N = np.shape(tiles[0].detach().numpy()[0,0,:,:])
    n=0
    for x in range(0, slice.shape[0], IMG_WIDTH):
        for y in range(0, slice.shape[1], IMG_HEIGHT):
            this_tile = Slice(tiles[n].detach().numpy()[0,0,:,:])
            M, N = np.shape(slice[x:x + IMG_WIDTH, y:y + IMG_HEIGHT])
            slice[x:x + IMG_WIDTH, y:y + IMG_HEIGHT] = this_tile.norm_max().reshape(M,N).slice
            n+=1
    return Slice(slice)


# main code
def infer(PATH_IMG_INFER, PATH_MODEL_PARAMS, PATH_INFER_SAVE, DEPTH, NUM_CHANNELS, MULT_CHAN, NUM_CLASSES,
          Z_RANGE, IMG_WIDTH, IMG_HEIGHT):

    ### instantiate model and load the model parameters
    my_model = MyModel(n_in_channels=NUM_CHANNELS, mult_chan=MULT_CHAN, depth=DEPTH)
    my_model.load_state_dict(torch.load(PATH_MODEL_PARAMS, map_location=torch.device('cpu')))
    my_model.eval()


    ### read in the tiff and place into a ZStack object
    stack = ZStack(path=PATH_IMG_INFER, zrange=Z_RANGE)

    # separate zslices; assign each to its own Slice object, and hold them all in a list
    slices = [Slice(x) for x in stack.images]

    # split each slice into tiles
    tiles = np.array([slices[z].tile(IMG_WIDTH, IMG_HEIGHT) for z in range(len(slices))])

    # normalize (z-score) the tiles before passing to model
    [[tiles[y][x].normalize() for x in range(0, tiles.shape[1])] for y in range(0, tiles.shape[0])]

    # reshape data; h=z_slices, w=numtiles for each z-slice
    h, w = np.shape(tiles)
    flat_tiles = np.zeros((h*w, 1, IMG_WIDTH, IMG_HEIGHT), dtype=np.float32)
    for i in range(h*w):
        flat_tiles[i] = tiles.flatten(order='C')[i].reshape(IMG_WIDTH,IMG_HEIGHT).slice

    # load data into pytorch data structs
    dataset = FormsDataset(flat_tiles, num_classes=NUM_CLASSES)
    hold = []
    data_loader = DataLoader(dataset, batch_size=1, shuffle=False)
    for i, images in enumerate(data_loader,1):
      images = images.type(torch.FloatTensor)
      hold.append(images)

    # now lets perform inference on the tiles, store them in 'predictions'
    predictions = []
    for tile in hold:
        predictions.append(my_model(tile))

    # and lets time ourselves
    print("--- Inference: {} seconds ---".format(time.time() - start_time))


    ### now we have to stitch our images back together!
    unflat_predictions = np.array(predictions).reshape((h,w))
    stack_infer = []
    for z in unflat_predictions:
        stack_infer.append(stitch(z, IMG_WIDTH=IMG_WIDTH, IMG_HEIGHT=IMG_HEIGHT).toimage())


    stack_infer[0].save(PATH_INFER_SAVE, save_all=True, append_images=stack_infer[1:])

    print("--- Finish: {} seconds ---".format(time.time() - start_time))


if __name__=='__main__':

    with open(sys.argv[1], 'r') as f:
        json_text = f.read()

    args = json.loads(json_text, strict=False)
    infer(args['PATH_IMG_INFER'], args['PATH_MODEL_PARAMS'], args['PATH_INFER_SAVE'],
          literal_eval(args['DEPTH']), literal_eval(args['NUM_CHANNELS']),
          literal_eval(args['MULT_CHAN']), literal_eval(args['NUM_CLASSES']),
          literal_eval(args['Z_RANGE']), literal_eval(args['IMG_WIDTH']),
          literal_eval(args['IMG_HEIGHT']))