FROM debian:bullseye-slim
MAINTAINER Daniel Sobe <daniel.sobe@sorben.com>

# normal call
# docker build -t speech_recognition_cfg_word_classes .

# rebuild from scratch
# docker build -t speech_recognition_cfg_word_classes . --no-cache

# enable in case you want to install tools from contrib or non-free
# RUN sed -i 's/ main/ main contrib non-free/' /etc/apt/sources.list

RUN apt update

# generic tools install 
RUN apt install -y g++ make git procps nano

##########################################
# Build dlabpro software (incl recognizer)
##########################################

RUN git clone https://github.com/ZalozbaDev/dLabPro.git dLabPro
RUN cd dLabPro && git checkout 0ffc81647d5bf89e39d57a697dad3b8ae1be2d7b

# build both binaries
RUN apt install -y libreadline-dev portaudio19-dev
RUN cd dLabPro && make -C programs/dlabpro RELEASE && make -C programs/recognizer RELEASE 

