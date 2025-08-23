import torch
import torchvision.transforms as transforms
import torchvision.models as models
from PIL import Image

# Load pretrained ResNet18
model = models.resnet18(weights=models.ResNet18_Weights.DEFAULT)
model.eval()

# Preprocess
transform = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225]
    )
])

# Load image
img = Image.open("sample.jpg")
img_t = transform(img).unsqueeze(0)

# Predict
with torch.no_grad():
    outputs = model(img_t)
    _, predicted = outputs.max(1)

print("Predicted class index:", predicted.item())
