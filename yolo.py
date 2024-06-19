import cv2
from ultralytics import YOLO
from PIL import Image


# Initialize YOLOv8 model
model = YOLO("yolov8n.pt")  # Replace with your model path and name


results = model(source=2, show=True, conf=0.4, save=True)