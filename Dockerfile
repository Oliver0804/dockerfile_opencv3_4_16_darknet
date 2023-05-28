# 指定基底映像檔
FROM nvidia/cuda:11.0.3-devel-ubuntu20.04

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
    libopencv-highgui-dev 


# 安裝Python並設定Python環境
RUN apt-get install -y python3-dev python3-numpy \
    libtcmalloc-minimal4 \
    && ln -s /usr/lib/libtcmalloc_minimal.so.4 /usr/lib/libtcmalloc.so


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

# 安裝Darknet
RUN git clone https://github.com/AlexeyAB/darknet.git \
    && cd darknet \
    && sed -i 's/OPENCV=0/OPENCV=1/' Makefile \
    && sed -i 's/GPU=0/GPU=1/' Makefile \
    && make \
    && cp darknet /usr/bin


RUN export DISPLAY=:1
RUN apt-get update
RUN apt-get install -qqy x11-apps

# 設定預設命令
CMD ["bash"]
