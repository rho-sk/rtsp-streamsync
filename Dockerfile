FROM ubuntu:20.04

ENV HOME "/home"

RUN apt-get update && \
  apt-get install -y \
    git && \
    rm -rf /var/lib/apt/lists/*

###############################################################################
#
#							mv-extractor library (legacy version)
#
###############################################################################

# Build h264-videocap from source
RUN cd $HOME && git clone --depth 1 -b v0.0.0 https://github.com/rho-sk/mv-extractor.git video_cap
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Bratislava
RUN cd $HOME/video_cap && chmod +x ./install.sh
RUN cd $HOME/video_cap && ./install.sh
# Set environment variables
ENV PATH "$PATH:$HOME/bin"
ENV PKG_CONFIG_PATH "$PKG_CONFIG_PATH:$HOME/ffmpeg_build/lib/pkgconfig"

# patch video_cap for python 3.8
COPY patch/mv-extractor/py_video_cap.cpp  $HOME/video_cap/src

RUN cd $HOME/video_cap && \
  python3 setup.py install

###############################################################################
#
#							Python stream-sync module
#
###############################################################################

WORKDIR $HOME/stream_sync

COPY setup.py $HOME/stream_sync
COPY src $HOME/stream_sync/src/

# Install stream_sync Python module
RUN cd /home/stream_sync && \
  python3 setup.py bdist

WORKDIR $HOME

CMD ["sh", "-c", "tail -f /dev/null"]
