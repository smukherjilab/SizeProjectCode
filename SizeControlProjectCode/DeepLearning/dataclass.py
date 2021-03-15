# Define dataset class to feed into U-Net. 

from torch.utils.data import Dataset, DataLoader
import numpy as np

# inherits Dataset class from PyTorch
class FormsDataset(Dataset):
    def __init__(self, images, num_classes: int, transforms=None):
        self.images = images
        self.num_classes = num_classes
        self.transforms = transforms

    def __getitem__(self, idx):
        image = self.images[idx]
        image = image.astype(np.float32)
        image = image

        return image

    def __len__(self):
        return len(self.images)
