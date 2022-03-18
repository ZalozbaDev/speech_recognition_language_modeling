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

############################################
# Fetch UASR tooling
############################################

RUN git clone https://github.com/ZalozbaDev/UASR.git UASR
RUN cd UASR && git checkout 2452801de688d0843edd718e5cd1a9c41c8fc90c

############################################
# Build openfst and ngram tooling
############################################

# packages do not exist for bullseye, thus the build from source
# later distributions might have packages again, so check when upgrading!

RUN apt install -y wget

RUN wget https://www.openfst.org/twiki/pub/FST/FstDownload/openfst-1.8.2.tar.gz
RUN wget https://www.openfst.org/twiki/pub/GRM/NGramDownload/ngram-1.3.14.tar.gz

RUN tar xvfz openfst-1.8.2.tar.gz
RUN cd openfst-1.8.2 && LIBS=-latomic ./configure --enable-far && make && make install

RUN tar xvfz ngram-1.3.14.tar.gz
RUN cd ngram-1.3.14 && LIBS=-latomic ./configure && make && make install

