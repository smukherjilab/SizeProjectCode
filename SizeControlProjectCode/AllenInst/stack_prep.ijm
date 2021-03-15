
n=8;

home = "/Users/asakalish/Desktop/RebuttalPipeline/Lipid_droplets/Camera/SD/";
orgs_stack = "Organelle_fields/lipidFilter10ms003.tif";
//cells = "pathtocells"

orgs_savepath = "/Users/asakalish/Desktop/RebuttalPipeline/Lipid_droplets/Camera/SD/Organelle_blocks_raw/";
//cells_savepath = "/Users/asakalish/Projects/LD_test/Input2/"
open(home+orgs_stack);

startIter = 0;   // ie, the number of files already in that folder!
z = 31
field = 3

run("Duplicate...","duplicate");
id = getImageID(); 
title = getTitle(); 
getLocationAndSize(locX, locY, sizeW, sizeH); 
width = getWidth(); 
height = getHeight(); 
tileWidth = width / n; 
tileHeight = height / n; 
iter = 0
for (y = 0; y < n; y++) { 
	offsetY = y * height / n; 
	for (x = 0; x < n; x++) { 
		iter = iter + 1;
		itername =  "field_" + field + "y" + (y+1) + "x" + (x+1);// "field_" + field + "_" + iter;
		offsetX = x * width / n; 
		selectImage(id); 
		call("ij.gui.ImageWindow.setNextLocation", locX + offsetX, locY + offsetY); 
		tileTitle = title + " [" + (x+1) + "," + (y+1) + "]"; 
		run("Duplicate...", "duplicate"); 
		makeRectangle(offsetX, offsetY, tileWidth, tileHeight); 
		run("Crop"); 
		setOption("ScaleConversions",true);
		run("8-bit");
		saveAs("Tiff",orgs_savepath + itername);
		close();
	} 
} 
selectImage(id); 
close();
close();

//open(home+cells);
//run("Duplicate...","duplicate");
//id = getImageID(); 
//title = getTitle(); 
//getLocationAndSize(locX, locY, sizeW, sizeH); 
//width = getWidth(); 
//height = getHeight(); 
//tileWidth = width / n; 
//tileHeight = height / n; 
//iter = 0
//for (y = 0; y < n; y++) { 
//	offsetY = y * height / n; 
//	for (x = 0; x < n; x++) { 
//		iter = iter + 1;
//		itername = "field_" + field + "_" + iter;
//		offsetX = x * width / n; 
//		selectImage(id); 
//		call("ij.gui.ImageWindow.setNextLocation", locX + offsetX, locY + offsetY); 
//		tileTitle = title + " [" + x + "," + y + "]"; 
//		run("Duplicate...", "duplicate"); 
//		makeRectangle(offsetX, offsetY, tileWidth, tileHeight); 
//		run("Crop"); 
//		setOption("ScaleConversions",true);
//		run("8-bit");
//		saveAs("Tiff",cells_savepath + itername);
//		close();
//	} 
//} 
//selectImage(id); 
//close();
//close();