Here's the code I've been using for U-Net related things. Passing your fluorescent images through the U-Net is meant to replace deconvolution as a preprocessing step. Replacing the deconvolution with the U-Net may speed up preprocessing and greatly enhance image quality. Deconvolving an entire stack can take hours; passing a 31z stack through the U-Net should take less than a minute, and usually clean up the image more effectively & intelligently.

I train the U-Net using the notebooks in 'Google Colab Notebooks'. Google Colab gives free access to GPUs, which is very nice.
After training, I download the model parameters and perform inference on new data, locally on my machine (this step shouldn't require a GPU, as the training does). I've been using the popular IDE PyCharm.

You can try out a pretrained model by downloading (or cloning into) the repo here. 
You'll need the following files: 'Dataclass.py', 'Model.py', 'Slice.py', 'Stack.py', 'mito_inference.py'

I setup the files so that you can perform inference with the pretrained model from the command line, with just 1 line of code:

```
python mito_inference.py path_to_json.json
```

where 'path_to_json.json' is a JSON file holding the parameters (e.g. paths to your images, range of z slices you want to process, etc)

Note: JSON's are basically just txt files; to create one, first create a txt file and then save with extension '.json'

A diagram to illustrate the workflow of the script. Parameters are color coded to the step where they are most used (an aid for debugging purposes); each box roughly corresponds to 1 cell in the .ipynb script

![schematic](https://github.com/smukherjilab/SizeProjectCode/blob/master/DeepLearning/pictures/Screen%20Shot%202020-04-25%20at%206.58.56%20PM.png)
