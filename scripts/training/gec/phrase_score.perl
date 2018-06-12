use warnings;
use strict;
use Getopt::Long "GetOptions";
use FindBin qw($RealBin);
use File::Spec::Functions;
use File::Spec::Unix;
use File::Basename;

sub safesystem {
  print STDERR "Executing: @_\n";
  system(@_);
  if ($? == -1) {
      print STDERR "ERROR: Failed to execute: @_\n  $!\n";
      exit(1);
  }
  elsif ($? & 127) {
      printf STDERR "ERROR: Execution of: @_\n  died with signal %d, %s coredump\n",
          ($? & 127),  ($? & 128) ? 'with' : 'without';
      exit(1);
  }
  else {
    my $exitcode = $? >> 8;
    print STDERR "Exit code: $exitcode\n" if $exitcode;
    return ! $exitcode;
  }
}


$ENV{"LC_ALL"} = "C";
my $SCRIPTS_ROOTDIR = $RealBin;
if ($SCRIPTS_ROOTDIR eq '') {
    $SCRIPTS_ROOTDIR = dirname(__FILE__);

}

#$SCRIPTS_ROOTDIR =~ s/\training$//;
$SCRIPTS_ROOTDIR =$SCRIPTS_ROOTDIR."/../..";
my($___CORPUS, $___F, $___E, $___EXTRACT_FILE, $___ALIGNMENT_FILE, $___MODEL_DIR, $___LEXICAL_FILE );

my $_HELP = 1
    unless &GetOptions('corpus=s' => \$___CORPUS,
		       'f=s' => \$___F,
		       'e=s' => \$___E,
		       'alignment_file=s' => \$___ALIGNMENT_FILE,
		       'extract_file=s' => \$___EXTRACT_FILE,
		       'model_dir=s' => \$___MODEL_DIR,
		       'lex_file=s' => \$___LEXICAL_FILE);

if ($_HELP) {
    print "Train Phrase Model";

}


#my $___CORPUS="/home/versionx/Documents/data/eagles-dummy/data/post_process/eagles.0.0min-10max.train.5000.spacy.tok.clean.detoken.post";
#my $___F="inc";
#my $___E="cor";
#my $___EXTRACT_FILE="/home/versionx/Documents/data/eagles-dummy/data/post_process/eagles.0.0min-10max.train.5000.spacy.tok.clean.detoken.post/extract";
#my $___ALIGNMENT_FILE="/home/versionx/Documents/data/eagles-dummy/data/post_process/eagles.0.0min-10max.train.5000.spacy.tok.clean.detoken.post";
#my $___LEXICAL_FILE="/home/versionx/Documents/data/eagles-dummy/data/post_process/lex";
#my $___MODEL_DIR="/home/versionx/Documents/data/eagles-dummy/data/post_process";

my $___TEMP_DIR = $___MODEL_DIR;
my $_SCORE_OPTIONS;
my $___PHRASE_SCORER="phrase-extract";
my $___NOFORK=1;
my $___CONTINUE=0;

my $_CORES=24;
my $SORT_EXEC="sort";
my $__SORT_BUFFER_SIZE;
my $__SORT_BATCH_SIZE;
my $__SORT_COMPRESS;
my $__SORT_PARALLEL;

my $PHRASE_SCORE = "$SCRIPTS_ROOTDIR/../bin/score";

$PHRASE_SCORE = "$SCRIPTS_ROOTDIR/generic/score-parallel.perl $_CORES \"$SORT_EXEC $__SORT_BUFFER_SIZE $__SORT_BATCH_SIZE $__SORT_COMPRESS $__SORT_PARALLEL\" $PHRASE_SCORE";
my $MEMSCORE = "$SCRIPTS_ROOTDIR/../bin/memscore";
my $PHRASE_CONSOLIDATE = "$SCRIPTS_ROOTDIR/../bin/consolidate";

my @_PHRASE_TABLE;
my $_OMIT_WORD_ALIGNMENT;
my $_GHKM_SOURCE_LABELS_FILE;
my $_TARGET_SYNTACTIC_PREFERENCES_LABELS_FILE;
my $_GHKM_PARTS_OF_SPEECH_FILE;
my $___MEMSCORE_OPTIONS = "-s ml -s lexweights \$LEX_E2F -r ml -r lexweights \$LEX_F2E -s const 2.718";
my $_HIERARCHICAL;
my $FLEX_SCORER;
my $debug;
my $___GLUE_GRAMMAR_FILE;# /home/apurvnagvenkar/Documents/mt-dummy-data/train/glue-grammar
my $_GLUE_GRAMMAR;
my $_UNKNOWN_WORD_LABEL_FILE;
my $_UNKNOWN_WORD_SOFT_MATCHES_FILE;
my $_PCFG;
my $_ALT_DIRECT_RULE_SCORE_1;
my $_ALT_DIRECT_RULE_SCORE_2;
my $_PHRASE_ORIENTATION;
my $_PHRASE_ORIENTATION_PRIORS_FILE;
my $_GHKM;
my $_GHKM_TREE_FRAGMENTS;
my $_GHKM_SOURCE_LABELS;
my $_GHKM_PARTS_OF_SPEECH;
my $_GHKM_PARTS_OF_SPEECH_FACTOR;
my $_GHKM_STRIP_BITPAR_NONTERMINAL_LABELS;
my $_SOURCE_SYNTAX;
my $_TARGET_SYNTAX;
my $_TARGET_SYNTACTIC_PREFERENCES;
#my $max_length="";
my $_EXTRACT_OPTIONS;
my $___NOT_FACTORED=1;
my $___TRANSLATION_FACTORS;
my $___ALIGNMENT_STEM;
my $___REORDERING_FACTORS;
my $_EPPEX;

my $_INSTANCE_WEIGHTS_FILE;
my $_TARGET_CONSTITUENT_BOUNDARIES;
my $_FLEXIBILITY_SCORE;
my $_MMSAPT;

my $ZCAT="gzip -cd";
my $GZIP_EXEC="gzip";


### (6) PHRASE SCORING
&score_phrase_factored();
sub score_phrase_factored {
    print STDERR "(6) score phrases @ ".`date`;
    my @SPECIFIED_TABLE = @_PHRASE_TABLE;
    if ($___NOT_FACTORED) {
	print STDERR "NOT FActored ".$___NOT_FACTORED;
	my $file = "$___MODEL_DIR/".($_HIERARCHICAL?"rule-table":"phrase-table");
	$file = shift @SPECIFIED_TABLE if scalar(@SPECIFIED_TABLE);
	&score_phrase($file,$___LEXICAL_FILE,$___EXTRACT_FILE);
    }
    else {
	my $table_id = 0;
	foreach my $factor (split(/\+/,$___TRANSLATION_FACTORS)) {
	    print STDERR "(6) [$factor] score phrases @ ".`date`;
	    my ($factor_f,$factor_e) = split(/\-/,$factor);
	    my $file = "$___MODEL_DIR/".($_HIERARCHICAL?"rule-table":"phrase-table").".$factor";
	    $file = shift @SPECIFIED_TABLE if scalar(@SPECIFIED_TABLE);
	    &score_phrase($file,$___LEXICAL_FILE.".".$factor,$___EXTRACT_FILE.".".$factor,$table_id);
	    $table_id++;
	}
    }
}

sub score_phrase {
    my ($ttable_file,$lexical_file,$extract_file,$table_id) = @_;

    if ($___PHRASE_SCORER eq "phrase-extract") {
        &score_phrase_phrase_extract($ttable_file,$lexical_file,$extract_file,$table_id);
    } elsif ($___PHRASE_SCORER eq "memscore") {
        &score_phrase_memscore($ttable_file,$lexical_file,$extract_file);
    } else {
        die "ERROR: Unknown phrase scorer: ".$___PHRASE_SCORER;
    }
}

sub score_phrase_phrase_extract {
    my ($ttable_file,$lexical_file,$extract_file,$table_id) = @_;

    # distinguish between score and consolidation options
    my $ONLY_DIRECT = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /OnlyDirect/);
    my $PHRASE_COUNT = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /PhraseCount/);
    my $LOW_COUNT = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /LowCountFeature/);
    my ($SPARSE_COUNT_BIN,$COUNT_BIN,$DOMAIN) = ("","","");
    $SPARSE_COUNT_BIN = $1 if defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /SparseCountBinFeature ([\s\d]*\d)/;
    $COUNT_BIN = $1 if defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /\-CountBinFeature ([\s\d]*\d)/;
    $DOMAIN = $1 if defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /(\-+[a-z]*Domain[a-z]+ .+)/i;
    $DOMAIN =~ s/ \-.+//g;
    if ($DOMAIN =~ /^(.+) table ([\d\,]+) *$/) {
      my ($main_spec,$specified_tables) = ($1,$2);
      $DOMAIN = "--IgnoreSentenceId";
      foreach my $specified_table_id (split(/,/,$specified_tables)) {
	$DOMAIN = $main_spec if $specified_table_id == $table_id;
      }
    }
    my $SINGLETON = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /Singleton/);
    my $CROSSEDNONTERM = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /CrossedNonTerm/);

    my $UNALIGNED_COUNT = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /UnalignedPenalty/);
    my ($UNALIGNED_FW_COUNT,$UNALIGNED_FW_F,$UNALIGNED_FW_E);
    if (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /UnalignedFunctionWordPenalty +(\S+) +(\S+)/) {
      $UNALIGNED_FW_COUNT = 1;
      $UNALIGNED_FW_F = $1;
      $UNALIGNED_FW_E = $2;
    }
    my $MIN_SCORE = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /MinScore *(\S+)/) ? $1 : undef;
    my $GOOD_TURING = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /GoodTuring/);
    my $KNESER_NEY = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /KneserNey/);
    my $LOG_PROB = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /LogProb/);
    my $NEG_LOG_PROB = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /NegLogProb/);
    my $NO_LEX = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /NoLex/);
    my $MIN_COUNT = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /MinCount ([\d\.]+)/) ? $1 : undef;
    my $MIN_COUNT_HIERARCHICAL = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /MinCountHierarchical ([\d\.]+)/) ? $1 : undef;
    my $SOURCE_LABELS = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /SourceLabels/);
    my $SOURCE_LABEL_COUNTS_LHS = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /SourceLabelCountsLHS/);
    my $SPAN_LENGTH = (defined($_SCORE_OPTIONS) && $_SCORE_OPTIONS =~ /SpanLength/);
    my $CORE_SCORE_OPTIONS = "";
    $CORE_SCORE_OPTIONS .= " --LogProb" if $LOG_PROB;
    $CORE_SCORE_OPTIONS .= " --NegLogProb" if $NEG_LOG_PROB;
    $CORE_SCORE_OPTIONS .= " --NoLex" if $NO_LEX;
	$CORE_SCORE_OPTIONS .= " --Singleton" if $SINGLETON;
	$CORE_SCORE_OPTIONS .= " --CrossedNonTerm" if $CROSSEDNONTERM;
	$CORE_SCORE_OPTIONS .= " --SourceLabels" if $SOURCE_LABELS;
	$CORE_SCORE_OPTIONS .= " --SourceLabelCountsLHS " if $SOURCE_LABEL_COUNTS_LHS;

    my $substep = 1;
    my $isParent = 1;
    my @children;

    for my $direction ("f2e","e2f") {
      if ($___NOFORK and @children > 0) {
        waitpid((shift @children), 0);
		  $substep+=2;
      }
      my $pid = fork();

      if ($pid == 0)
      {
	      next if $___CONTINUE && -e "$ttable_file.half.$direction";
	      next if $___CONTINUE && $direction eq "e2f" && -e "$ttable_file.half.e2f.gz";
	      my $inverse = "";
              my $extract_filename = $extract_file;
	      if ($direction eq "e2f") {
	          $inverse = "--Inverse";
                  $extract_filename = $extract_file.".inv";
              }

	      my $extract = "$extract_filename.sorted.gz";

	      print STDERR "(6.".($substep++).")  creating table half $ttable_file.half.$direction @ ".`date`;

        my $cmd = "$PHRASE_SCORE $extract $lexical_file.$direction $ttable_file.half.$direction.gz $inverse";
        $cmd .= " --Hierarchical" if $_HIERARCHICAL;
        $cmd .= " --NoWordAlignment" if $_OMIT_WORD_ALIGNMENT;
        $cmd .= " --KneserNey" if $KNESER_NEY;
        $cmd .= " --GoodTuring" if $GOOD_TURING && $inverse eq "";
        $cmd .= " --SpanLength" if $SPAN_LENGTH && $inverse eq "";
        $cmd .= " --UnalignedPenalty" if $UNALIGNED_COUNT;
        $cmd .= " --UnalignedFunctionWordPenalty ".($inverse ? $UNALIGNED_FW_F : $UNALIGNED_FW_E) if $UNALIGNED_FW_COUNT;
        $cmd .= " --MinCount $MIN_COUNT" if $MIN_COUNT;
        $cmd .= " --MinCountHierarchical $MIN_COUNT_HIERARCHICAL" if $MIN_COUNT_HIERARCHICAL;
        $cmd .= " --PCFG" if $_PCFG;
        $cmd .= " --UnpairedExtractFormat" if $_ALT_DIRECT_RULE_SCORE_1 || $_ALT_DIRECT_RULE_SCORE_2;
        $cmd .= " --ConditionOnTargetLHS" if $_ALT_DIRECT_RULE_SCORE_1;
        $cmd .= " --TreeFragments" if $_GHKM_TREE_FRAGMENTS;
        $cmd .= " --PhraseOrientation" if $_PHRASE_ORIENTATION;
        $cmd .= " --PhraseOrientationPriors $_PHRASE_ORIENTATION_PRIORS_FILE" if $_PHRASE_ORIENTATION && defined($_PHRASE_ORIENTATION_PRIORS_FILE);
        $cmd .= " --SourceLabels $_GHKM_SOURCE_LABELS_FILE" if $_GHKM_SOURCE_LABELS && defined($_GHKM_SOURCE_LABELS_FILE);
        $cmd .= " --TargetSyntacticPreferences $_TARGET_SYNTACTIC_PREFERENCES_LABELS_FILE" if $_TARGET_SYNTACTIC_PREFERENCES && defined($_TARGET_SYNTACTIC_PREFERENCES_LABELS_FILE);
        $cmd .= " --PartsOfSpeech $_GHKM_PARTS_OF_SPEECH_FILE" if $_GHKM_PARTS_OF_SPEECH && defined($_GHKM_PARTS_OF_SPEECH_FILE);
        $cmd .= " --TargetConstituentBoundaries" if $_TARGET_CONSTITUENT_BOUNDARIES;
        $cmd .= " --FlexibilityScore=$FLEX_SCORER" if $_FLEXIBILITY_SCORE;
        $cmd .= " $DOMAIN" if $DOMAIN;
        $cmd .= " $CORE_SCORE_OPTIONS" if defined($_SCORE_OPTIONS);

				# sorting
				if ($direction eq "e2f" || $_ALT_DIRECT_RULE_SCORE_1 || $_ALT_DIRECT_RULE_SCORE_2) {
					$cmd .= " 1 ";
				}
				else {
					$cmd .= " 0 ";
				}

        print STDERR $cmd."\n";
        safesystem($cmd) or die "ERROR: Scoring of phrases failed";

        exit();
      }
      else
      { # parent
    	  push(@children, $pid);
      }

    }

    # wait for everything is finished
    if ($isParent)
    {
        foreach (@children) {
	        waitpid($_, 0);
        }
    }
    else
    {
        die "shouldn't be here";
    }

    # merging the two halves
    print STDERR "(6.6) consolidating the two halves @ ".`date`;
    return if $___CONTINUE && -e "$ttable_file.gz";
    my $cmd = "$PHRASE_CONSOLIDATE $ttable_file.half.f2e.gz $ttable_file.half.e2f.gz /dev/stdout";
    $cmd .= " --Hierarchical" if $_HIERARCHICAL;
    $cmd .= " --LogProb" if $LOG_PROB;
    $cmd .= " --NegLogProb" if $NEG_LOG_PROB;
    $cmd .= " --OnlyDirect" if $ONLY_DIRECT;
    $cmd .= " --PhraseCount" if $PHRASE_COUNT;
    $cmd .= " --LowCountFeature" if $LOW_COUNT;
    $cmd .= " --CountBinFeature $COUNT_BIN" if $COUNT_BIN;
    $cmd .= " --SparseCountBinFeature $SPARSE_COUNT_BIN" if $SPARSE_COUNT_BIN;
    $cmd .= " --MinScore $MIN_SCORE" if $MIN_SCORE;
    $cmd .= " --GoodTuring $ttable_file.half.f2e.gz.coc" if $GOOD_TURING;
    $cmd .= " --KneserNey $ttable_file.half.f2e.gz.coc" if $KNESER_NEY;
    $cmd .= " --SourceLabels $_GHKM_SOURCE_LABELS_FILE" if $_GHKM_SOURCE_LABELS && defined($_GHKM_SOURCE_LABELS_FILE);
    $cmd .= " --TargetSyntacticPreferences $_TARGET_SYNTACTIC_PREFERENCES_LABELS_FILE" if $_TARGET_SYNTACTIC_PREFERENCES && defined($_TARGET_SYNTACTIC_PREFERENCES_LABELS_FILE);
    $cmd .= " --PartsOfSpeech $_GHKM_PARTS_OF_SPEECH_FILE" if $_GHKM_PARTS_OF_SPEECH && defined($_GHKM_PARTS_OF_SPEECH_FILE);

    $cmd .= " | $GZIP_EXEC -c > $ttable_file.gz";

    safesystem($cmd) or die "ERROR: Consolidating the two phrase table halves failed";
    if (! $debug) { safesystem("rm -f $ttable_file.half.*") or die("ERROR"); }
}

sub score_phrase_memscore {
    my ($ttable_file,$lexical_file,$extract_file) = @_;

    return if $___CONTINUE && -e "$ttable_file.gz";

    my $options = $___MEMSCORE_OPTIONS;
    $options =~ s/\$LEX_F2E/$lexical_file.f2e/g;
    $options =~ s/\$LEX_E2F/$lexical_file.e2f/g;

    # The output is sorted to avoid breaking scripts that rely on the
    # sorting behaviour of the previous scoring algorithm.
    my $cmd = "$MEMSCORE $options | LC_ALL=C sort $__SORT_BUFFER_SIZE $__SORT_BATCH_SIZE -T $___TEMP_DIR | $GZIP_EXEC >$ttable_file.gz";
    if (-e "$extract_file.gz") {
        $cmd = "$ZCAT $extract_file.gz | ".$cmd;
    } else {
        $cmd = $cmd." <".$extract_file;
    }

    print $cmd."\n";
    safesystem($cmd) or die "ERROR: Scoring of phrases failed";
}

