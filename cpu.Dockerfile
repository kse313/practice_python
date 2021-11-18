#local 빌드 시
FROM tensorflow/tensorflow:2.6.0-jupyter

#CUDA 는 GPU할때 추가

#카카오 ubuntu archive mirror server 추가 / 다운로드 속도 향상
RUN  sed -i "s@archive.ubuntu.com@mirror.kakao.com@g" /etc/apt/sources.list && apt-get update

# openjdk java vm 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \ 
    wget \
    build-essential \
    libboost-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    g++ \
    gcc \
    openjdk-8-jdk \
    python3-dev \
    python3-pip \
    curl \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6\
    libxrender1 \
    libssl-dev \
    libzmq3-dev \
    vim \
    git

RUN apt-get update

ARG CONDA_DIR=/opt/conda

#add to path
ENV PATH $CONDA_DIR/bin:$PATH

#Install miniconda
RUN echo "export PATH=$CONDA_DIR/bin"'$PATH' > /etc/profile.d/conda.sh && \
    curl -sL https://repo.anaconda.com/miniconda/Miniconda3-py37_4.10.3-Linux-x86_64.sh -o ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

#Conda 가상환경 생성
RUN conda config --set always_yes yes --set changeps1 no && \
    conda create -y -q -n py37 python=3.7

ENV PATH /opt/conda/envs/py37/bin:$PATH
ENV CONDA_DEFAULT_ENV py37
ENV CONDA_PREFIX /opt/conda/envs/py37

#패키지 설치
RUN pip install setuptools && \ 
    pip install mkl && \
    pip install numpy && \
    pip install scipy && \
    pip install pandas==1.2.5 && \
    pip install jupyter notebook && \
    pip install matplotlib && \ 
    pip install seaborn && \
    pip install hyperopt && \
    pip install optuna && \
    pip install missingno && \
    pip install mlxtend && \
    pip install catboost && \
    pip install kaggle && \
    pip install folium && \
    pip install librosa && \
    pip install nbconvert && \
    pip install Pillow && \
    pip install tqdm && \
    pip install tensorflow==2.6.0 && \
    pip install tensorflow-datasets && \
    pip install gensim && \
    pip install nltk && \
    pip install wordcloud && \
    apt-get install -y graphviz && pip install graphviz
    
#RUN pip install --upgrade cython && \
#   pip install --upgrade cysignals && \
#    pip install pyfasttext && \
#    pip install fasttext && \
#    pip install tranformers

#RUN pip install pystan-2.19.1.1 &&\
#    pip install fbprophet

#RUN pip install "setencepiece 꺽새 0.1.90" 

#cmake 설치 3.16
RUN wget https://cmake.org/files/v3.16/cmake-3.16.2.tar.gz && \
    tar -xvzf cmake-3.16.2.tar.gz && \
    cd cmake-3.16.2 && \
    ./bootstrap && \
    make && \
    make install

ENV PATH=/usr/local/bin:{PATH}

# 나눔고딕 폰트 설치, D2Coding 폰트 설치
# matplotlib에 Nanum 폰트 추가 20211118 -y 추가
RUN apt-get update ** \
    apt-get install -y fonts-nanum* && \
    mkdir ~/.local/share/fonts && \
    cd ~/.local/share/fonts && \
    wget https://github.com/naver/d2codingfont/releases/download/VER1.3.2/D2Coding-Ver1.3.2-20180524.zip && \
    unzip D2Coding-Ver1.3.2-20180524.zip && \
    mkdir /usr/share/fonts/truetype/D2Coding && \
    cp ./D2Coding/*.ttf /usr/share/fonts/truetype/D2Coding/ && \
    cp /usr/share/fonts/truetype/nanum/Nanum* /opt/conda/lib/python3.7/site-packages/matplotlib/mpl-data/fonts/ttf/ && \
    fc-cache -fv && \
    rm -rf D2Coding* && \
    rm -rf ~/.cache/matplotlib/*

# konlpy, py-hanspell, soynlp 패키지 설치 
RUN pip install konlpy && \
    pip install git+https://github.com/ssut/py-hanspell.git && \
    pip install soynlp && \
    pip install soyspacing && \
    pip install krwordrank && \
    pip install soykeyword && \
    pip install git+https://github.com/haven-jeon/PyKoSpacing.git

# 형태소 분석기 mecab 설치
RUN cd /tmp && \
    wget "https://www.dropbox.com/s/9xls0tgtf3edgns/mecab-0.996-ko-0.9.2.tar.gz?dl=1" && \
    tar zxfv mecab-0.996-ko-0.9.2.tar.gz?dl=1 && \
    cd mecab-0.996-ko-0.9.2 && \
    ./configure && \
    make && \
    make check && \
    make install && \
    ldconfig

RUN cd /tmp && \
    wget "https://www.dropbox.com/s/i8girnk5p80076c/mecab-ko-dic-2.1.1-20180720.tar.gz?dl=1" && \
    apt install -y autoconf && \
    tar zxfv mecab-ko-dic-2.1.1-20180720.tar.gz?dl=1 && \
    cd mecab-ko-dic-2.1.1-20180720 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    ldconfig

# 형태소 분석기 mecab 파이썬 패키지 설치
RUN cd /tmp && \
    git clone https://bitbucket.org/eunjeon/mecab-python-0.996.git && \
    cd mecab-python-0.996 && \
    python setup.py build && \
    python setup.py install
# Remove the CUDA stubs
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH_NO_STUBS"

RUN apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* ** \
    conda clean -a -y
# locale 설정
RUN apt-get update && apt-get install -y vim locales tzdata && \
    locale-gen ko_KR.UTF-8 && locale -a && \
    ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# LANG 환경변수 설정
ENV LANG ko_KR.UTF-8

# Jupyter Notebook config 파일 생성
RUN jupyter notebook --generate-config

# config 파일 복사 (jupyter_notebook_config.py 파일 참고)
COPY jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py

# 설치 완료 후 테스트용 ipynb
COPY test.ipynb /home/jupyter/test.ipynb

# 기본
EXPOSE 8888
# jupyter notebook 의 password를 지정하지 않으면 보안상 취약하므로 지정하는 것을 권장
CMD jupyter notebook --ip 0.0.0.0 --allow-root --no-browser