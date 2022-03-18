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

############################################
# Fetch pretrained acousic models
############################################

RUN git clone https://github.com/ZalozbaDev/speech_recognition_pretrained_models speech_recognition_pretrained_models
RUN cd speech_recognition_pretrained_models && git checkout 7f59924e254283498c87e0f7e4638ef850b58571

########################################################
# Setup locale to properly support sorbian diacritics
########################################################

RUN apt-get install -y locales

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

ENV LC_ALL en_US.UTF-8 
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en     

############################################
# Convert and merge grammars
############################################

RUN mkdir -p output

# collect all files for merging
RUN mkdir -p grammars
COPY inputs/grm/*                        grammars/
COPY inputs/word_classes/dates/*         grammars/
COPY inputs/word_classes/numbers_times/* grammars/

# add tooling
ADD grm2ofst.xtp /
ADD grmmerge.py /

RUN apt install -y python3

RUN DLABPRO_HOME=/dLabPro/ UASR_HOME=/UASR/ python3 grmmerge.py grammars/smart_lamp_hsb_evl_fsg_num.txt

############################################
# Plot grammars
############################################

RUN mkdir -p plots/

ADD generate_plots.sh /

RUN apt install -y graphviz

RUN /generate_plots.sh

################################################################
# Package grammar, lexicon and acoustic model for recognition 
################################################################

RUN mkdir -p uasr-data/db-hsb-asr-exp/grammatics/smartlamp_numbers/grm/
RUN cp /grammars/smart_lamp_hsb_evl_fsg_num.txt_ofst.txt   uasr-data/db-hsb-asr-exp/grammatics/smartlamp_numbers/grm/
RUN cp /grammars/smart_lamp_hsb_evl_fsg_num.txt_lex.txt    uasr-data/db-hsb-asr-exp/grammatics/smartlamp_numbers/grm/

RUN mkdir -p uasr-data/db-hsb-asr-exp/grammatics/smartlamp_numbers/model/
RUN cp /speech_recognition_pretrained_models/2022_02_21/classes.txt      uasr-data/db-hsb-asr-exp/grammatics/smartlamp_numbers/model/
RUN cp /speech_recognition_pretrained_models/2022_02_21/feainfo.object   uasr-data/db-hsb-asr-exp/grammatics/smartlamp_numbers/model/
RUN cp /speech_recognition_pretrained_models/2022_02_21/3_7.hmm          uasr-data/db-hsb-asr-exp/grammatics/smartlamp_numbers/model/

ADD inputs/cfg/package.cfg /

RUN UASR_HOME=uasr /dLabPro/bin.release/dlabpro /UASR/scripts/dlabpro/tools/REC_PACKDATA.xtp rec package.cfg

############################################
# Evaluation of resulting grammar
############################################

# copy audio files
RUN mkdir -p sig/
COPY inputs/sig/*  sig/

ADD inputs/cfg/recognizer.cfg /

RUN /dLabPro/bin.release/recognizer -cfg recognizer.cfg /sig/0002HSB.flst

############################################
# fetch intermediates and results
############################################

## mkdir -p output && rm -rf ./output/*

# fetch converted grammar 
## docker run --mount type=bind,source="$(pwd)"/output,target=/output/ -it speech_recognition_cfg_word_classes cp /grammars/smart_lamp_hsb_evl_fsg_num.txt_ofst.txt.save.txt /output/

# fetch all plots
## docker run --mount type=bind,source="$(pwd)"/output,target=/output/ -it speech_recognition_cfg_word_classes cp -r /plots /output/
