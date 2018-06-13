Mosesdecoder for GEC adaptation

Step 0: Preprocessing Alignement and Parllel Data:

Processes the alignment and parallel data and generates the tokenized parallel data with proper alignment



```shell
export MOSESDECODER=
export ALIGNMENT_PATH=
export INCORRECT_FILE=
export CORRECT_FILE=

export OUT_ALIGNMENT_PATH=
export OUT_INCORRECT_FILE=
export OUT_CORRECT_FILE=


python $MOSESDECODER/scripts/training/gec/process_parllel_data_and_align.py -align_file $ALIGNMENT_PATH -inc $INCORRECT_FILE -cor $CORRECT_FILE -out_align_file $OUT_ALIGNMENT_PATH -out_inc $OUT_INCORRECT_FILE -out_cor $OUT_CORRECT_FILE
```

Step 1: Lexical Translation:

 

```shell
export MOSESDECODER=
export CORPUSPATH=
export ALIGN_FILE=
export LEX_PATH=

export TARGET=cor
export SOURCE=inc
export ALIGN_EXTENSION=align
```



```shell

perl $MOSESDECODER/scripts/training/gec/lexical_table.perl -corpus $CORPUS_PATH -e $TARGET -f $SOURCE -alignment_file $ALIGN_FILE -alignment $ALIGN_EXTENSION -lex_file $LEX_PATH

```





Step 2: Phrase Extraction



```shell
export MOSESDECODER=
export CORPUSPATH=
export ALIGN_FILE=
export EXTRACT_PATH=

export TARGET=cor
export SOURCE=inc
export ALIGN_EXTENSION=align
```

```shell
perl $MOSESDECODER/scripts/training/gec/phrase_extraction.perl -corpus $CORPUS_PATH -e $TARGET -f $SOURCE -alignment_file $ALIGN_FILE -alignment $ALIGN_EXTENSION -extract_file $EXTRACT_PATH

```



Step 3: Phrase Scoring



```shell
export MOSESDECODER=
export CORPUSPATH=
export ALIGN_FILE=
export EXTRACT_PATH=
export LEX_PATH=
export MODEL_PATH=

export TARGET=cor
export SOURCE=inc
```

```shell
perl $MOSESDECODER/scripts/training/gec/phrase_score.perl -corpus $CORPUS_PATH -e $TARGET -f $SOURCE -alignment_file $ALIGN_FILE -model_dir $MODEL_PATH -extract_file $EXTRACT_PATH -lex_file $LEX_PATH
```





Step 4: Phrase Table Processing



```shell
export MOSESDECODER=
export input_pt=
export output_pt=
```

```shell
python  $MOSESDECODER/scripts/training/gec/prune_phrase_table.py -inp_pt $input_pt -out_pt $output_pt
```

