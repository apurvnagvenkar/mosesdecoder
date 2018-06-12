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
my($___CORPUS, $___F, $___E, $___EXTRACT_FILE, $___ALIGNMENT_FILE, $___ALIGNMENT );

my $_HELP = 1
    unless &GetOptions('corpus=s' => \$___CORPUS,
		       'f=s' => \$___F,
		       'e=s' => \$___E,
		       'alignment_file=s' => \$___ALIGNMENT_FILE,
		       'alignment=s' => \$___ALIGNMENT,
		       'extract_file=s' => \$___EXTRACT_FILE);

if ($_HELP) {
    print "Train Phrase Model";

}


#my $___CORPUS="/home/versionx/Documents/data/eagles-dummy/data/post_process/eagles.0.0min-10max.train.5000.spacy.tok.clean.detoken.post";

#my $___F="inc";
#my $___E="cor";
#my $___EXTRACT_FILE="/home/versionx/Documents/data/eagles-dummy/data/post_process/eagles.0.0min-10max.train.5000.spacy.tok.clean.detoken.post/extract";

#my $___ALIGNMENT_FILE="/home/versionx/Documents/data/eagles-dummy/data/post_process/eagles.0.0min-10max.train.5000.spacy.tok.clean.detoken.post";


#my $___ALIGNMENT_FILE="/home/versionx/Documents/data/eagles-dummy/train1/model/aligned";


#my $___ALIGNMENT= 'align';

my $REORDERING_LEXICAL=1;
my $___MAX_PHRASE_LENGTH=7;
my $___MAX_LEXICAL_REORDERING=0;
my @REORDERING_MODELS;
my %REORDERING_MODEL_TYPES = ();
my $_BASELINE_EXTRACT;
my $_HIERARCHICAL;
#my $SCRIPTS_ROOTDIR="/home/versionx/Documents/mosesdecoder/scripts";
my $PHRASE_EXTRACT="$SCRIPTS_ROOTDIR/../bin/extract";
my $RULE_EXTRACT="$SCRIPTS_ROOTDIR/../bin/extract-rules";

my $_CORES=24;
my $SPLIT_EXEC="split";
my $SORT_EXEC="sort";
my $__SORT_BUFFER_SIZE;
my $__SORT_BATCH_SIZE;
my $__SORT_COMPRESS;
my $__SORT_PARALLEL;
$PHRASE_EXTRACT = "$SCRIPTS_ROOTDIR/generic/extract-parallel.perl $_CORES $SPLIT_EXEC \"$SORT_EXEC $__SORT_BUFFER_SIZE $__SORT_BATCH_SIZE $__SORT_COMPRESS $__SORT_PARALLEL\" $PHRASE_EXTRACT";


$RULE_EXTRACT = "$SCRIPTS_ROOTDIR/generic/extract-parallel.perl $_CORES $SPLIT_EXEC \"$SORT_EXEC $__SORT_BUFFER_SIZE $__SORT_BATCH_SIZE $__SORT_COMPRESS $__SORT_PARALLEL\" $RULE_EXTRACT";

my $EPPEX="$SCRIPTS_ROOTDIR/../bin/eppex";

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

### (5) PHRASE EXTRACTION

&extract_phrase_factored();

sub extract_phrase_factored {
    print STDERR "(5) extract phrases @ ".`date`;
    if ($___NOT_FACTORED) {
	&extract_phrase($___CORPUS.".".$___F,
			$___CORPUS.".".$___E,
			$___EXTRACT_FILE,
			0,1,$REORDERING_LEXICAL);
    }
    else {
	my %EXTRACT_FOR_FACTOR = ();
	my $table_number = 0;
	my @FACTOR_LIST = ();
	foreach my $factor (split(/\+/,"$___TRANSLATION_FACTORS")) {
	    my $factor_key = $factor.":".&get_max_phrase_length($table_number++);
	    push @FACTOR_LIST, $factor_key;
	    $EXTRACT_FOR_FACTOR{$factor_key}{"translation"}++;
	}
	if ($REORDERING_LEXICAL) {
	    foreach my $factor (split(/\+/,"$___REORDERING_FACTORS")) {
		my $factor_key = $factor.":".&get_max_phrase_length(-1); # max
		if (!defined($EXTRACT_FOR_FACTOR{$factor_key}{"translation"})) {
		    push @FACTOR_LIST, $factor_key;
		}
		$EXTRACT_FOR_FACTOR{$factor_key}{"reordering"}++;
	    }
	}
	$table_number = 0;
	foreach my $factor_key (@FACTOR_LIST) {
	    my ($factor,$max_length) = split(/:/,$factor_key);
	    print STDERR "(5) [$factor] extract phrases (max length $max_length)@ ".`date`;
	    my ($factor_f,$factor_e) = split(/\-/,$factor);

	    &reduce_factors($___CORPUS.".".$___F,
			    $___ALIGNMENT_STEM.".".$factor_f.".".$___F,
			    $factor_f);
	    &reduce_factors($___CORPUS.".".$___E,
			    $___ALIGNMENT_STEM.".".$factor_e.".".$___E,
			    $factor_e);

	    &extract_phrase($___ALIGNMENT_STEM.".".$factor_f.".".$___F,
			    $___ALIGNMENT_STEM.".".$factor_e.".".$___E,
			    $___EXTRACT_FILE.".".$factor,
			    $table_number++,
			    defined($EXTRACT_FOR_FACTOR{$factor_key}{"translation"}),
			    defined($EXTRACT_FOR_FACTOR{$factor_key}{"reordering"}));
	}
    }
}

sub get_max_phrase_length {
    my ($table_number) = @_;

    # single length? that's it then
    if ($___MAX_PHRASE_LENGTH =~ /^\d+$/) {
	return $___MAX_PHRASE_LENGTH;
    }

    my $max_length = 0;
    my @max = split(/,/,$___MAX_PHRASE_LENGTH);

    # maximum of specified lengths
    if ($table_number == -1) {
	foreach (@max) {
	    $max_length = $_ if $_ > $max_length;
	}
	return $max_length;
    }

    # look up length for table
    $max_length = $max[0]; # fallback: first specified length
    if ($#max >= $table_number) {
	$max_length = $max[$table_number];
    }
    return $max_length;
}

sub get_extract_reordering_flags {
    if ($___MAX_LEXICAL_REORDERING) {
	return " --model wbe-mslr --model phrase-mslr --model hier-mslr";
    }
    return "" unless @REORDERING_MODELS;
    my $config_string = "";
    for my $type ( keys %REORDERING_MODEL_TYPES) {
	$config_string .= " --model $type-".$REORDERING_MODEL_TYPES{$type};
    }
    return $config_string;
}

sub extract_phrase {
    my ($alignment_file_f,$alignment_file_e,$extract_file,$table_number,$ttable_flag,$reordering_flag) = @_;
    my $alignment_file_a = $___ALIGNMENT_FILE.".".$___ALIGNMENT;
    # Make sure the corpus exists in unzipped form
    my @tempfiles = ();
    foreach my $f ($alignment_file_e, $alignment_file_f, $alignment_file_a) {
     if (! -e $f && -e $f.".gz") {
       safesystem("gunzip < $f.gz > $f") or die("Failed to gunzip corpus $f");
       push @tempfiles, "$f.gz";
     }
    }
    my $cmd;
    my $suffix = (defined($_BASELINE_EXTRACT) && $PHRASE_EXTRACT !~ /extract-parallel.perl/) ? ".new" : "";
    if ($_HIERARCHICAL)
    {
        my $max_length = &get_max_phrase_length($table_number);

        $cmd = "$RULE_EXTRACT $alignment_file_e $alignment_file_f $alignment_file_a $extract_file$suffix";
        $cmd .= " --GlueGrammar $___GLUE_GRAMMAR_FILE" if $_GLUE_GRAMMAR;
        $cmd .= " --UnknownWordLabel $_UNKNOWN_WORD_LABEL_FILE" if $_TARGET_SYNTAX && defined($_UNKNOWN_WORD_LABEL_FILE);
        $cmd .= " --UnknownWordSoftMatches $_UNKNOWN_WORD_SOFT_MATCHES_FILE" if $_TARGET_SYNTAX && defined($_UNKNOWN_WORD_SOFT_MATCHES_FILE);
        $cmd .= " --PCFG" if $_PCFG;
        $cmd .= " --UnpairedExtractFormat" if $_ALT_DIRECT_RULE_SCORE_1 || $_ALT_DIRECT_RULE_SCORE_2;
        $cmd .= " --ConditionOnTargetLHS" if $_ALT_DIRECT_RULE_SCORE_1;
        $cmd .= " --PhraseOrientation" if $_PHRASE_ORIENTATION;
        $cmd .= " --PhraseOrientationPriors $_PHRASE_ORIENTATION_PRIORS_FILE" if defined($_PHRASE_ORIENTATION_PRIORS_FILE);
        if (defined($_GHKM))
        {
          $cmd .= " --TreeFragments" if $_GHKM_TREE_FRAGMENTS;
          $cmd .= " --SourceLabels" if $_GHKM_SOURCE_LABELS;
          $cmd .= " --PartsOfSpeech" if $_GHKM_PARTS_OF_SPEECH;
          $cmd .= " --PartsOfSpeechFactor" if $_GHKM_PARTS_OF_SPEECH_FACTOR;
          $cmd .= " --StripBitParLabels" if $_GHKM_STRIP_BITPAR_NONTERMINAL_LABELS;
        }
        else
        {
          $cmd .= " --SourceSyntax" if $_SOURCE_SYNTAX;
          $cmd .= " --TargetSyntax" if $_TARGET_SYNTAX;
          $cmd .= " --TargetSyntacticPreferences" if $_TARGET_SYNTACTIC_PREFERENCES;
          $cmd .= " --MaxSpan $max_length";
        }
        $cmd .= " ".$_EXTRACT_OPTIONS if defined($_EXTRACT_OPTIONS);
    }
    else
    {
		if ( $_EPPEX ) {
			# eppex sets max_phrase_length itself (as the maximum phrase length for which any Lossy Counter is defined)
      		$cmd = "$EPPEX $alignment_file_e $alignment_file_f $alignment_file_a $extract_file$suffix $_EPPEX";
		}
		else {
      my $max_length = &get_max_phrase_length($table_number);
      print "MAX $max_length $reordering_flag $table_number\n";
      $max_length = &get_max_phrase_length(-1) if $reordering_flag;

      $cmd = "$PHRASE_EXTRACT $alignment_file_e $alignment_file_f $alignment_file_a $extract_file$suffix $max_length";
		}
      if ($reordering_flag) {
        $cmd .= " orientation";
        $cmd .= get_extract_reordering_flags();
        $cmd .= " --NoTTable" if !$ttable_flag;
      }
      $cmd .= " ".$_EXTRACT_OPTIONS if defined($_EXTRACT_OPTIONS);
    }

    $cmd .= " --GZOutput ";
    $cmd .= " --InstanceWeights $_INSTANCE_WEIGHTS_FILE " if defined $_INSTANCE_WEIGHTS_FILE;
    $cmd .= " --BaselineExtract $_BASELINE_EXTRACT" if defined($_BASELINE_EXTRACT) && $PHRASE_EXTRACT =~ /extract-parallel.perl/;
    $cmd .= " --TargetConstituentBoundaries" if $_TARGET_CONSTITUENT_BOUNDARIES;
    $cmd .= " --FlexibilityScore" if $_FLEXIBILITY_SCORE;
    $cmd .= " --NoTTable" if $_MMSAPT;

    map { die "File not found: $_" if ! -e $_ } ($alignment_file_e, $alignment_file_f, $alignment_file_a);
    print STDERR "$cmd\n";
    safesystem("$cmd") or die "ERROR: Phrase extraction failed (missing input files?)";

    if (defined($_BASELINE_EXTRACT) && $PHRASE_EXTRACT !~ /extract-parallel.perl/) {
      print STDERR "merging with baseline extract from $_BASELINE_EXTRACT\n";
      safesystem("$ZCAT $_BASELINE_EXTRACT.gz $extract_file$suffix.gz | $GZIP_EXEC > $extract_file.gz")
        if -e "$extract_file$suffix.gz";
      safesystem("$ZCAT $_BASELINE_EXTRACT.inv.gz $extract_file$suffix.inv.gz | $GZIP_EXEC > $extract_file.inv.gz")
        if -e "$extract_file$suffix.inv.gz";
      safesystem("$ZCAT $_BASELINE_EXTRACT.o.gz $extract_file$suffix.o.gz | $GZIP_EXEC > $extract_file.o.gz")
	if -e "$extract_file$suffix.o.gz";
      safesystem("rm $extract_file$suffix.gz")
        if -e "$extract_file$suffix.gz";
      safesystem("rm $extract_file$suffix.inv.gz")
        if -e "$extract_file$suffix.inv.gz";
      safesystem("rm $extract_file$suffix.o.gz")
        if -e "$extract_file$suffix.o.gz";
    }

    foreach my $f (@tempfiles) {
      unlink $f;
    }
}

