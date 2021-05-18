# image-processing

The rebuttal for the size control project ~~required~~ encouraged me to clean up the code a bit more. 

Version 1 contains the workflow I used early in the rebuttal, when we had less data. As we acquired more and more images, I wrote the code in Version 2 to make things go faster/easier. They're both the same code but slightly different implementations, with the main difference being that Version 2 is written more compactly. 

I'd recommend going straight to Version 2. Download the whole folder and run the analysis from `analyze_data.m`, which calls the functions in the other folders. See `plotting_fxns` for functions that help plot statistics we're interested in (eg number versus average size). See `support_fxns` for the functions called in `analyze_data.m`. See `viz_fxns` for functions that I like to use to visualize the data as I go along. 

