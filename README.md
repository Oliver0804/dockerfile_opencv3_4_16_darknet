# dockerfile_opencv3_4_16_darknet
## build image
```
docker build -t <your_image_name> --no-cache .
```
ex. docker build -t oliver_darknet --no-cache .

編譯完成後可透過
```
docker images 
```
查詢是否正確編譯


## 1.容器內操作
### 部屬docker容器
```
docker run --gpus all -it <your_image_name>
```
ex. docker run --gpus all -it oliver_darknet

### 下載yolov3權重檔
```
cd /darknet
wget https://pjreddie.com/media/files/yolov3.weights
```


### 運行測試
```
cd /darknet
./darknet detect cfg/yolov3.cfg yolov3.weights data/dog.jpg
```

## 2.容器外操作

### 於設備中 任意 clone yolo項目
```
git clone https://github.com/AlexeyAB/darknet
cd ./darknet
wget https://pjreddie.com/media/files/yolov3.weights
```
運行，此命令用運行完後即刻結束(--rm)
```
docker run --gpus all --rm -v $PWD:/workspace -w /workspace <your_image_name> darknet detect cfg/yolov3.cfg yolov3.weights data/dog.jpg
```
ex. docker run --gpus all --rm -v $PWD:/workspace -w /workspace oliver_darknet darknet detect cfg/yolov3.cfg yolov3.weights data/dog.jpg

## 待測試命令
使用攝影機,運行yolov3
```
docker run --gpus all --rm -v $PWD:/workspace -w /workspace --privileged -v /dev/video0:/dev/video0 --env DISPLAY=unix$DISPLAY -v $XAUTH:/root/.Xauthority -v /tmp/.X11-unix:/tmp/.X11-unix oliver_darknet ./darknet detector demo cfg/coco.data cfg/yolov3.cfg yolov3.weights -c 0
```

docker run --runtime=nvidia --rm -v $PWD:/workspace -w /workspace \
--privileged \ 給予硬體權限
-v /dev/video0:/dev/video0 \ 掛載攝像頭 會根據webcam編號改變
--env DISPLAY=unix$DISPLAY \
-v $XAUTH:/root/.Xauthority \
-v /tmp/.X11-unix:/tmp/.X11-unix \
daisukekobayashi/darknet:gpu-cv-cc86 \ 使用darknet映像檔
darknet detector demo data/coco.data yolov3.cfg yolov3.weights -c 0
