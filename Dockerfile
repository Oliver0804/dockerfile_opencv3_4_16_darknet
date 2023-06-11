# 指定基底映像檔
FROM nvidia/cuda:11.7.1-devel-ubuntu20.04

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
RUN apt-get install -y python3-dev python3-numpy python3-pip \
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

# 安裝 PyTorch
RUN pip3 install torch torchvision --extra-index-url https://download.pytorch.org/whl/cu113

# 下載 AlphaPose
RUN git clone https://github.com/MVIG-SJTU/AlphaPose.git

# 設定環境變數並安裝相關套件
RUN export PATH=/usr/local/cuda/bin/:$PATH && \
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64/:$LD_LIBRARY_PATH && \
    pip3 install cython && \
    apt-get install -y libyaml-dev

# 安裝 AlphaPose
WORKDIR /AlphaPose
RUN python3 setup.py build develop --user

# 安裝 PyTorch3D（選擇性，只有在需要視覺化時使用）
RUN conda install -c fvcore -c iopath -c conda-forge fvcore iopath && \
    conda install -c bottler nvidiacub && \
    pip install git+https://github.com/facebookresearch/pytorch3d.git@stable

# 切換回工作目錄
WORKDIR /



# 安裝 PyTorch
#RUN pip3 install torch torchvision --extra-index-url https://download.pytorch.org/whl/cu113

# 下載 AlphaPose
#RUN git clone https://github.com/MVIG-SJTU/AlphaPose.git

# 設定環境變數並安裝相關套件
#RUN export PATH=/usr/local/cuda/bin/:$PATH && \
#    export LD_LIBRARY_PATH=/usr/local/cuda/lib64/:$LD_LIBRARY_PATH && \
#    pip3 install cython && \
#    apt-get install -y libyaml-dev

# 安裝 AlphaPose
#WORKDIR /AlphaPose
#RUN python3 setup.py build develop --user

# 安裝 PyTorch3D（選擇性，只有在需要視覺化時使用）
#RUN conda install -c fvcore -c iopath -c conda-forge fvcore iopath && \
#    conda install -c bottler nvidiacub && \
#    pip install git+https://github.com/facebookresearch/pytorch3d.git@stable



RUN export DISPLAY=:1
RUN apt-get update
RUN apt-get install -qqy x11-apps

# 切換回工作目錄
WORKDIR /


# 設定預設命令
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--allow-root"]

