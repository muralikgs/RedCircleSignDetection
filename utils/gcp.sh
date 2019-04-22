#!/usr/bin/env bash

# New VM
rm -rf yolov3 weights coco
git clone https://github.com/ultralytics/yolov3
bash yolov3/weights/download_yolov3_weights.sh && cp -r weights yolov3
bash yolov3/data/get_coco_dataset.sh
git clone https://github.com/cocodataset/cocoapi && cd cocoapi/PythonAPI && make && cd ../.. && cp -r cocoapi/PythonAPI/pycocotools yolov3
sudo reboot now

# Re-clone
sudo rm -rf yolov3
git clone https://github.com/ultralytics/yolov3  # master
# git clone -b test --depth 1 https://github.com/ultralytics/yolov3 yolov3_test  # branch
cp -r weights yolov3
cp -r cocoapi/PythonAPI/pycocotools yolov3
cd yolov3

# Train
python3 train.py

# Resume
python3 train.py --resume

# Detect
python3 detect.py

# Test
python3 test.py --save-json

# Git pull
git pull https://github.com/ultralytics/yolov3  # master
git pull https://github.com/ultralytics/yolov3 test  # branch

# Test Darknet training
python3 test.py --weights ../darknet/backup/yolov3.backup

# Copy latest.pt TO bucket
gsutil cp yolov3/weights/latest1gpu.pt gs://ultralytics

# Copy latest.pt FROM bucket
gsutil cp gs://ultralytics/latest.pt yolov3/weights/latest.pt
wget https://storage.googleapis.com/ultralytics/yolov3/latest_v1_0.pt -O weights/latest_v1_0.pt
wget https://storage.googleapis.com/ultralytics/yolov3/best_v1_0.pt -O weights/best_v1_0.pt

# Debug/Development
sudo rm -rf yolov3
git clone https://github.com/ultralytics/yolov3  # master
# git clone -b test --depth 1 https://github.com/ultralytics/yolov3 yolov3_test  # branch
cp -r weights yolov3
cp -r cocoapi/PythonAPI/pycocotools yolov3
cd yolov3
python3 train.py --nosave --data data/coco_32img.data --var 4 && mv results.txt results_t2.txt
python3 train.py --nosave --data data/coco_32img.data --var 5 && mv results.txt results_t3.txt
python3 -c "from utils import utils; utils.plot_results()"
gsutil cp results*.txt gs://ultralytics
gsutil cp results.png gs://ultralytics
sudo shutdown

mv ../train.py .

rm results*.txt  # WARNING: removes existing results
python3 train.py --nosave --data data/coco_1img.data && mv results.txt results3_1img.txt
python3 train.py --nosave --data data/coco_10img.data && mv results.txt results3_10img.txt
python3 train.py --nosave --data data/coco_100img.data && mv results.txt results4_100img.txt
python3 train.py --nosave --data data/coco_100img.data --transfer && mv results.txt results3_100imgTL.txt
# python3 train.py --nosave --data data/coco_1000img.data && mv results.txt results_1000img.txt
python3 -c "from utils import utils; utils.plot_results()"
gsutil cp results*.txt gs://ultralytics
gsutil cp results.png gs://ultralytics
sudo shutdown


