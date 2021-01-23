## AllenCell pipelines

In this folder, I have saved all of the pipelines built on AllenCell's segmentation work.

Each organelle & imaging condition has its own pipeline. First, check out AllenCell's [Github](https://github.com/AllenCell/aics-segmentation) to download the necessary tools (very user-friendly). The code and a ML-based extension is outlined in this [paper](https://www.biorxiv.org/content/10.1101/491035v2). 

After following AllenCell's directions to install their tools, this is the pipeline I use: 

*assumes that input is a single-channel Zstack of organelles*

##### 0
Deconvolve your images (may skip this step if you want to work directly with raw fluorescence and/or you didn't use the camera)

##### 1
In ImageJ, run *stack_prep.ijm* to chunk Zstack into smaller blocks
   *default splits a 2044x2048x31 stack into 64 blocks of 256x256x31. This can be changed by adjusting param n inside code*
   
##### 2
In your terminal: 
   - activate your conda environment. For me, on my mac, I run "conda activate segmentation", where *segmentation* is the name of my conda environment
   - enter: *batch_processing --workflow_name name --struct_ch 0 --output_dir savepath per_dir --input_dir inputpath --data_type .tif*
   
   *name* refers to the segmentation routine to be used. you can look at them inside *aics-segmentation/aicssegmentation/structure_wrapper/*. E.g., for lipid droplets, I used *seg_gja1.py*, so *name*=gja1 . I use the 'playground' Jupyter notebooks to figure out the best parameters (and take advantage of AllenCell's awesome visualization tools), and then I edit the python file to use the parameters that work best. This [lookup table](https://www.allencell.org/segmenter.html#lookup-table) can help you choose which segmentation algorithm will work best. *seg_gja1.py* uses the same processing tools as the Jupyter notebook in the lipid droplets folder, etc for the other organelles and their playgrounds. 
   *struct_ch* tells you which channel the structures of interest are. I always put 0 because I only pass single-channel images as inputs. 
   *savepath* is the folder in which you want to save the binarized blocks
   *per_dir* is an input that tells the program to treat the input path as a directory
   *inputpath* is the folder which holds the blocks to be processed

##### 3
Finally, stitch the processed blocks together to construct a binary Zstack. 
  I do this in ImageJ: 
  *Plugins -> Stitching -> Grid/Collection stitching* with params *Type*=Filename defined position & *Order*=Defined by filename
  

