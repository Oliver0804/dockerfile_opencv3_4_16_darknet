# 指定基底映像檔
#FROM nvidia/cuda:11.7.1-devel-ubuntu20.04
FROM nvidia/cuda:11.3.0-devel-ubuntu20.04

# 安裝tzdata並設定時區
RUN apt-get update  && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata && \
	rm -rf /var/lib/apt/lists/*
    
RUN TZ=Asia/Taipei && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata


# 安裝基本工具
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    vim \
    unzip \
    yasm \
    pkg-config \
    libswscale-dev \
    libtbb2 \
    libtbb-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavformat-dev \
    libpq-dev \
    libopencv-highgui-dev \
    locales \
    libavcodec58 \
    ffmpeg \
    libyaml-dev



RUN export DISPLAY=:1
RUN apt-get update
RUN apt-get install -qqy x11-apps


# 安裝Python並設定Python環境
RUN apt-get install -y python3-dev python3-tk python3-pip \
    libtcmalloc-minimal4 \
    && ln -s /usr/lib/libtcmalloc_minimal.so.4 /usr/lib/libtcmalloc.so \
    && ln -s /usr/bin/python3 /usr/bin/python


# 安裝OpenCV
RUN git clone https://github.com/opencv/opencv.git \
    && cd opencv && git checkout 3.4.16 \
    && git clone https://github.com/opencv/opencv_contrib.git \
    && cd opencv_contrib && git checkout 3.4.16 \
    && cd .. \
    && mkdir build && cd build \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D WITH_CUDA=ON \
        -D ENABLE_FAST_MATH=1 \
        -D CUDA_FAST_MATH=1 \
        -D WITH_CUBLAS=1 \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules .. \
        -D BUILD_EXAMPLES=ON .. \
    && make -j12 \
    && make install


# 安裝 PyTorch
WORKDIR /root
RUN pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113
RUN pip install numpy==1.20 gdown youtube-dl
RUN pip install setuptools==45.2.0 

#配置jupyter
RUN pip install jupyter
EXPOSE 8888


# 設定環境變數並安裝相關套件
RUN export PATH=/usr/local/cuda/bin/:$PATH && \
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64/:$LD_LIBRARY_PATH && \
    export LANG=C.UTF-8 && \
    python -m pip install cython


# 安裝 AlphaPose
WORKDIR /root
RUN git clone https://github.com/MVIG-SJTU/AlphaPose.git
WORKDIR /root/AlphaPose
RUN export PATH=/usr/local/cuda/bin/:$PATH && \
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64/:$LD_LIBRARY_PATH && \
    export LANG=C.UTF-8 && \
    sed -i '/index_url=https:\/\/pypi\.tuna\.tsinghua\.edu\.cn\/simple/d' setup.cfg 
#RUN python setup.py build develop 

# 下載
WORKDIR /root/AlphaPose/yolo
RUN mkdir data && \
    cd data && \
#    wget https://pjreddie.com/media/files/yolov3.weights && \
#    wget https://pjreddie.com/media/files/yolov3-tiny.weights && \
    wget https://pjreddie.com/media/files/yolov3-spp.weights

WORKDIR /root/AlphaPose/pretrained_models
RUN gdown https://drive.google.com/u/0/uc?id=1kQhnMRURFiy7NsdS8EFL-8vtqEXOgECn
# 安裝 PyTorch3D（選擇性，只有在需要視覺化時使用）
#RUN conda install -c fvcore -c iopath -c conda-forge fvcore iopath && \
#    conda install -c bottler nvidiacub && \
#    pip install git+https://github.com/facebookresearch/pytorch3d.git@stable

# 切換回工作目錄
WORKDIR /


# 設定預設命令
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--allow-root"]
