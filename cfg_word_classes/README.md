# Context free grammars with word classes

This example takes an existing context-free grammar with placeholders for word classes. The grammar is
converted to OpenFST format, and the placeholders filled (merged) with the word class FSTs. Functionality
of the resulting grammar is tested with example sentences.

Inputs:

* lexicon and grammar in UASR format ("smart_lamp_hsb_evl_fsg_num.txt")
    * check directory inputs/grm
* word class definitions
    * dates
        * check directory inputs/word_classes/dates
    * numbers and times
        * check directory inputs/word_classes/numbers_times
    
* existing Upper Sorbian acoustic model ("3_7.hmm") and statistics ("feainfo.object") for evaluation
    * see https://github.com/ZalozbaDev/speech_recognition_pretrained_models
