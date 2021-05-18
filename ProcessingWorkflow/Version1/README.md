# image-processing

The rebuttal for the size control project ~~required~~ encouraged me to clean up the code a bit more. 

My usual workflow:

1) Check out the data with `look_data.m`

I normally crop out a cell to look at before looking at the whole field. Eg see sample data `pex3camera_example.tif` 

2) Use parameters found during checking out data to analyze the whole field in `analyze_data.m`

Note that you might often find yourself repeating (1) as different parts of dataset might provide new challenges (eg variations in SNR variation in centroids between cells)
