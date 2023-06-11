# Dockerfile Opencv3.4.16 and darknet（Yolo懶人包）
這個Dockerfile是用來建立一個深度學習開發環境的映像檔，該環境包含了NVIDIA CUDA、OpenCV，以及Darknet等關鍵元件，並且透過Docker的封裝特性，讓這個環境可以輕易地在不同的系統上進行部署和運行。

- 基底映像檔：我們從具有CUDA 11.0.3支援的Ubuntu 20.04映像檔開始建立我們的環境。

- 工具安裝：接著，我們安裝了一系列的基本工具，包括了C++編譯器、CMake、Git，以及一些其他必要的軟體包。

- Python環境設定：我們也安裝了Python以及相關的函式庫，並設定好了Python的執行環境。

- OpenCV安裝(3.4.16)：我們從GitHub上抓取OpenCV的源碼，並進行編譯和安裝。在編譯的過程中，我們有啟用CUDA支援以提供更好的效能。

- Darknet安裝：我們也從GitHub上抓取Darknet的源碼，並進行編譯和安裝。同樣地，我們有啟用CUDA和OpenCV支援。

- X11支援：為了能在Docker環境中顯示圖形介面，我們也進行了相關的設定。

最後，我們設定了預設的命令為啟動bash，這樣當你啟動這個Docker映像檔的時候，就會直接進入bash命令列介面。

## 使用簡介
1. 使用本github提供的Dockerfile進行映像黨建置
2. 進入容器中使用darknet
3. 在宿主機上clone darknet後於該入路進行操作「容器外操作」
2與3則一使用即可

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


## 1.容器內操作(於容器中進行操作)
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

## 2.容器外操作(離開即移除該容器,下次會基於映像檔重新部屬新的)

### 於設備中 任意 clone yolo項目
```
git clone https://github.com/AlexeyAB/darknet
cd ./darknet
wget https://pjreddie.com/media/files/yolov3.weights
```
運行，此命令用運行完後即刻結束(--rm)

![](https://github.com/Oliver0804/dockerfile_opencv3_4_16_darknet/blob/main/pic/%E6%88%AA%E5%9C%96%202023-05-28%20%E4%B8%8B%E5%8D%8810.42.25.png)
```
docker run --gpus all --rm -v $PWD:/workspace -w /workspace <your_image_name> darknet detect cfg/yolov3.cfg yolov3.weights data/dog.jpg
```
ex. docker run --gpus all --rm -v $PWD:/workspace -w /workspace oliver_darknet darknet detect cfg/yolov3.cfg yolov3.weights data/dog.jpg
![](https://github.com/Oliver0804/dockerfile_opencv3_4_16_darknet/blob/main/pic/%E6%88%AA%E5%9C%96%202023-05-28%20%E4%B8%8B%E5%8D%8810.43.01.png)


### 使用Jupyter notebook進行
```
docker-compose up
```
## TODO
### 進行更完整的測試:
1. 關於yolov3訓練與測試
2. yolov4 yolov7 與更版本tiny的測試
3. 整理個版本的weights方便使用..

## Weights 僅整理，並沒有完整驗證
| 模型名稱 | 權重文件路徑 |
|---------|------------|
| yolov4-csp-x-swish.weights | https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-csp-x-swish.weights |
| yolov4-csp-swish.weights | https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-csp-swish.weights |
| yolov4x-mish.weights | https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4x-mish.weights |
| yolov4-csp.weights | https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-csp.weights |
| yolov4.weights | https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_pre/yolov4.weights |
| yolov4-tiny.weights | https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-tiny.weights |
| enetb0-coco_final.weights | https://drive.google.com/open?id=1-AHO3tPi3tjyvtivOOZ3GDE2NtWSvKB_ |
| yolov3-openimages.weights | https://pjreddie.com/media/files/yolov3-openimages.weights |
| csresnext50-panet-spp-original-optimal_final.weights | https://drive.google.com/open?id=1MzTY44rLToO5APn8TZmfR7_ENSe5aZUn |
| yolov3-spp.weights | https://pjreddie.com/media/files/yolov3-spp.weights |
| csresnext50-panet-spp_final.weights | https://drive.google.com/open?id=1R5T6KrIh3h0w1BMS6If_GYDq6JrV9TPr |
| yolov3.weights | https://pjreddie.com/media/files/yolov3.weights |
| yolov3-tiny.weights | https://pjreddie.com/media/files/yolov3-tiny.weights |
| yolov3-tiny-prn.weights | https://drive.google.com/open?id=1fcbR0b4iyzmA3C8MyvqLc6P7E4I8bhgD |

## 待測試命令
使用攝影機,運行yolov3
```
docker run --gpus all --rm -v $PWD:/workspace -w /workspace --privileged -v /dev/video0:/dev/video0 --env DISPLAY=unix$DISPLAY -v $XAUTH:/root/.Xauthority -v /tmp/.X11-unix:/tmp/.X11-unix oliver_darknet ./darknet detector demo cfg/coco.data cfg/yolov3.cfg yolov3.weights -c 0
```
參數說明
docker run --runtime=nvidia --rm -v $PWD:/workspace -w /workspace \
--privileged \ 給予硬體權限
-v /dev/video0:/dev/video0 \ 掛載攝像頭 會根據webcam編號改變
--env DISPLAY=unix$DISPLAY \
-v $XAUTH:/root/.Xauthority \
-v /tmp/.X11-unix:/tmp/.X11-unix \
daisukekobayashi/darknet:gpu-cv-cc86 \ 使用darknet映像檔
darknet detector demo data/coco.data yolov3.cfg yolov3.weights -c 0
