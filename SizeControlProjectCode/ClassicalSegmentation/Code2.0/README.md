Description of code:

**process.m**: 
this is the function that processes data; returns processed images & volume/number measurements

**sweep_process.m**
this function will process the data for ranges of image-processing parameters; intended to help ensure that statistics provided by *process.m* are robust, and not artifacts of the image processing

**check_images.m**
this function compares raw images to labeled (binary) images; helpful for checking success of processing

**allometry_analysis.m**
an example of my workflow, pulled from a side-project on allometry in yeast

**get_volumes.m**
a helper function for *sweep_process.m* - allows you to run *sweep_process.m* on multiple datasets and then merge their statistics, for a more confident exploration of the image-processing parameter space. Specifically, merges the volume measurements 

**get_cellsizes.m**
same as above but for (2D) cell sizes

**conc_matrices.m**
a subroutine of the above "get" functions; merges matrices that have different # rows/cols
