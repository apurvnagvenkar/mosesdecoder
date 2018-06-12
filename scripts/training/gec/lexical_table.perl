use warnings;
use strict;
use Getopt::Long "GetOptions";
use FindBin qw($RealBin);
use File::Spec::Functions;
use File::Spec::Unix;
use File::Basename;
BEGIN { require "$RealBin/../LexicalTranslationModel.pm"; "LexicalTranslationModel"->import; }

my($___CORPUS, $___F, $___E, $___ALIGNMENT_FILE, $___ALIGNMENT, $___LEXICAL_FILE);
my $_HELP = 1
    unless &GetOptions('corpus=s' => \$___CORPUS,
		       'f=s' => \$___F,
		       'e=s' => \$___E,
		       'alignment_file=s' => \$___ALIGNMENT_FILE,
		       'alignment=s' => \$___ALIGNMENT,
		       'lex_file=s' => \$___LEXICAL_FILE);

if ($_HELP) {
    print "Train Phrase Model";

}

#my $___CORPUS="/home/versionx/Documents/data/eagles-dummy/data/post_process/eagles.0.0min-10max.train.5000.spacy.tok.clean.detoken.post";

#my $___CORPUS="/home/versionx/Documents/data/eagles-dummy/data/eagles.0.0min-10max.train.5000.spacy.tok.clean";

#my $___F="inc";
#my $___E="cor";

#my $___ALIGNMENT_FILE="/home/versionx/Documents/data/eagles-dummy/data/post_process/eagles.0.0min-10max.train.5000.spacy.tok.clean.detoken.post";

#my $___ALIGNMENT_FILE="/home/versionx/Documents/data/eagles-dummy/train1/model/aligned";


#my $___ALIGNMENT= 'align';
#my $___LEXICAL_FILE="/home/versionx/Documents/data/eagles-dummy/data/post_process/lex";

my $___LEXICAL_COUNTS="";

#my $_BASELINE_CORPUS="/home/versionx/Documents/data/eagles-dummy/data/post_process/eagles.0.0min-10max.train.5000.spacy.tok.clean.detoken.post";
#my $_BASELINE_ALIGNMENT="/home/versionx/Documents/data/eagles-dummy/data/post_process/eagles.0.0min-10max.train.5000.spacy.tok.clean.detoken.post".".".$___ALIGNMENT;

my $_INSTANCE_WEIGHTS_FILE="";

my $_BASELINE_CORPUS=$___ALIGNMENT_FILE;
my $_BASELINE_ALIGNMENT=$___ALIGNMENT_FILE.".".$___ALIGNMENT;

&get_lexical_factored();

sub get_lexical_factored {
    &get_lexical($___CORPUS.".".$___F,
		     $___CORPUS.".".$___E,
		     $___ALIGNMENT_FILE.".".$___ALIGNMENT,
		     $___LEXICAL_FILE,
		     $___LEXICAL_COUNTS,
                     $_BASELINE_CORPUS.".".$___F,
                     $_BASELINE_CORPUS.".".$___E,
                     $_BASELINE_ALIGNMENT,
                     $_INSTANCE_WEIGHTS_FILE);
}


