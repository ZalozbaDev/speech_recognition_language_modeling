FROM debian:bullseye-slim
MAINTAINER Daniel Sobe <daniel.sobe@sorben.com>

# normal call
# docker build -t speech_recognition_slm_word_classes .

# rebuild from scratch
# docker build -t speech_recognition_slm_word_classes . --no-cache

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
# Process text corpus with python script
############################################

RUN mkdir -p output

COPY inputs/corpus/smartlamp.corp           /
COPY inputs/phoneme_rules/exceptions_v3.txt /
COPY inputs/phoneme_rules/phonmap_v3.txt    /
COPY tools/BASgenerator.py                  /
COPY tools/HSB.yaml                         /

RUN apt install -y python3 python3-numpy python3-matplotlib python3-yaml

RUN python3 BASgenerator.py HSB.yaml || /bin/true

############################################
# Create statistical language model
############################################

RUN mkdir -p /lm

# combine lexica from corpus with additional words from word classes (not part of corpus)
COPY inputs/lexicon/word_class_lexicon.vocab /
RUN cat corpus/hsb.vocab word_class_lexicon.vocab > corpus/hsb_combined.vocab

# create symbols
RUN ngramsymbols --OOV_symbol="<unk>" corpus/hsb_combined.vocab lm/hsb.syms

# create corpus fst archive
RUN farcompilestrings --fst_type=compact --symbols=lm/hsb.syms --keep_symbols --unknown_symbol="<unk>" corpus/hsb.corp lm/hsb.far

# count n-grams (bigrams only)
RUN ngramcount --order=2 lm/hsb.far lm/hsb.cnts

# assemble model
RUN ngrammake --backoff --method=witten_bell lm/hsb.cnts lm/hsb.mod

# prune (optional)
RUN ngramshrink --method=relative_entropy --theta=1.0e-7 lm/hsb.mod lm/hsb.pru

# evaluation of not pruned and pruned models
RUN ngramperplexity --OOV_symbol="<unk>" lm/hsb.mod lm/hsb.far
RUN ngramperplexity --OOV_symbol="<unk>" lm/hsb.pru lm/hsb.far

######################################################
# Merge statistical language model and word classes
######################################################

RUN mkdir -p /merge

# collect all word class files
COPY inputs/word_classes/* merge/

# python tool MUST be in same folder as all data files
COPY tools/grmmerge.py merge/

# SLM needs to be converted to be in proper format for merging
# using the non-pruned SLM
RUN fstprint lm/hsb.mod > merge/hsb_tmp.txt
# replace PERCENT symbol with name of word class grammar file ("top level")
RUN cd merge && cat hsb_tmp.txt | sed -e 's/<epsilon>/<eps>/g' | sed -e 's/{PERCENT}\(.*\){PERCENT}/NUM1-100\1<eps>/' > hsb.txt

# finally run the merge itself
RUN cd merge && python3 grmmerge.py -lmw 10 -ofstin hsb.txt

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

# combine generated phonetical lexicon with word class lexicon (not part of corpus) 
RUN mkdir -p uasr-data/db-hsb-asr/grammatics/word_class_lm/lex/
COPY inputs/lexicon/word_class_lexicon.ulex /
# remove PERCENT placeholder from autogenerated lexicon
RUN cat uasr_configurations/lexicon/hsb_sampa.ulex | grep -v '{PERCENT}' > /hsb_sampa_filtered.ulex
RUN cat /hsb_sampa_filtered.ulex /word_class_lexicon.ulex > uasr-data/db-hsb-asr/grammatics/word_class_lm/lex/hsb.ulex

RUN mkdir -p uasr-data/db-hsb-asr/grammatics/word_class_lm/lm/
RUN cp /merge/hsb.txt_ofst.txt      uasr-data/db-hsb-asr/grammatics/word_class_lm/lm/
# don't forget to copy the input and output symbol files!!! Packaging will not warn you if these are not found!
RUN cp /merge/hsb.txt_ofst_is.txt   uasr-data/db-hsb-asr/grammatics/word_class_lm/lm/
RUN cp /merge/hsb.txt_ofst_os.txt   uasr-data/db-hsb-asr/grammatics/word_class_lm/lm/

RUN mkdir -p uasr-data/db-hsb-asr/grammatics/word_class_lm/model/
RUN cp /speech_recognition_pretrained_models/2022_02_21/classes.txt      uasr-data/db-hsb-asr/grammatics/word_class_lm/model/
RUN cp /speech_recognition_pretrained_models/2022_02_21/feainfo.object   uasr-data/db-hsb-asr/grammatics/word_class_lm/model/
RUN cp /speech_recognition_pretrained_models/2022_02_21/3_7.hmm          uasr-data/db-hsb-asr/grammatics/word_class_lm/model/

ADD inputs/cfg/package.cfg /

RUN UASR_HOME=uasr /dLabPro/bin.release/dlabpro /UASR/scripts/dlabpro/tools/REC_PACKDATA.xtp rec package.cfg

############################################
# Evaluation of resulting grammar
############################################

# copy audio files
RUN mkdir -p sig/
COPY inputs/sig/*  sig/

ADD inputs/cfg/recognizer.cfg /

RUN rm -f recognizer_log.txt
RUN /dLabPro/bin.release/recognizer -cfg recognizer.cfg /sig/list.flst 2>/dev/null | grep  'cmd:\|processing' | tee recognizer_log.txt


############################################
# fetch intermediates and results
############################################

## mkdir -p output && rm -rf ./output/*

# fetch SLM
## docker run --mount type=bind,source="$(pwd)"/output,target=/output/ -it speech_recognition_slm_word_classes cp /merge/hsb_tmp.txt /output/

# fetch merged grammar
## docker run --mount type=bind,source="$(pwd)"/output,target=/output/ -it speech_recognition_slm_word_classes cp /merge/hsb.txt_ofst.txt /output/

# fetch all plots
## docker run --mount type=bind,source="$(pwd)"/output,target=/output/ -it speech_recognition_slm_word_classes cp -r /plots /output/

# fetch merged phonetical lexicon
## docker run --mount type=bind,source="$(pwd)"/output,target=/output/ -it speech_recognition_slm_word_classes cp /uasr-data/db-hsb-asr/grammatics/word_class_lm/lex/hsb.ulex /output/

# fetch output files for recognizer
## docker run --mount type=bind,source="$(pwd)"/output,target=/output/ -it speech_recognition_slm_word_classes cp -r /uasr-data/db-hsb-asr/grammatics/word_class_lm/recognizer /output/
