### Purpose:
This U-Net is meant to replace deconvolution as a preprocessing step. 

Replacing the deconvolution with the U-Net may speed up preprocessing and greatly enhance image quality. Deconvolving an entire stack can take hours; passing a 31z stack through the U-Net should take less than a minute, and usually clean up the image more effectively & intelligently.

### Training:
I train the U-Net using the notebooks in _Google Colab Notebooks_. Google Colab gives free access to GPUs, which is very nice.

### Using the trained model:
After training, I download the model parameters and perform inference on new data, locally on my machine (this step shouldn't require a GPU, as the training does). I've been using the popular IDE PyCharm.

You can try out a pretrained model by downloading the files of (or cloning into) the repo here. 

You'll need the following files: _Dataclass.py_, _Model.py_, _Slice.py_, _Stack.py_, _mito_inference.py_

I setup the files so that you can perform inference with the pretrained model from the command line, with just 1 line of code:

```
python mito_inference.py path_to_json.json
```

where _path_to_json.json_ is a JSON file holding the parameters (e.g. paths to your images, range of z slices you want to process, etc)

__Pretrained models can be found in 'pretrained models'__

__An example JSON can be found in 'inference arguments'__

_Notes:_ 
  * _JSON's are basically just txt files; to create one, first create a txt file and then save with extension_ .json
  * _Models are trained with a particular structure in mind. E.g._ mito_inference.py _or_ unet_mito.pynb _are meant only to be used with mitochondria. There's nothing stopping you from applying the model to the wrong structure; your results are just unlikely to be good_
