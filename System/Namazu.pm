package System::Namazu;

use Manager::Dialog qw(ApproveCommands);
use MyFRDCSA qw(ConcatDir);
use PerlLib::EasyPersist;
use PerlLib::SwissArmyKnife;

use FileHandle;
use IO::File;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Type NamazuDir DataDir TargetFile IndexDir ConfigDir NamazuConfigFile
   MakeNamazuConfigFile SplitSize /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Type($args{Type});
  die "No type defined.\n" unless defined $self->Type;
  die "Type must be either 'list' or 'fulltext'.\n" unless ($self->Type eq "list" or $self->Type eq "fulltext");
  $self->NamazuDir
    ($args{NamazuDir});
  die "Storage directory not defined.\n" unless defined $self->NamazuDir;
  die "Storage directory not found.\n" unless -d $self->NamazuDir;
  $self->DataDir(ConcatDir($self->NamazuDir,"data"));
  $self->TargetFile(ConcatDir($self->DataDir,"target"));
  $self->IndexDir(ConcatDir($self->NamazuDir,"index"));
  $self->ConfigDir(ConcatDir($self->NamazuDir,"config"));
  $self->NamazuConfigFile(ConcatDir($self->ConfigDir,"namazu.config"));
  $self->MakeNamazuConfigFile(ConcatDir($self->ConfigDir,"mknmz.config"));
  $self->SplitSize(2000);
  if (-d $self->NamazuDir) {
    $self->InitializeDirectory();
  }
}

sub InitializeDirectory {
  my ($self,%args) = @_;
  return if -d $self->DataDir;

  # create the directories
  system "mkdir -p ".shell_quote($self->DataDir);
  system "mkdir -p ".shell_quote($self->IndexDir);
  system "mkdir -p ".shell_quote($self->ConfigDir);

  my $fh1 = IO::File->new();
  $fh1->open(">".$self->MakeNamazuConfigFile);
  print $fh1 $makenamazuconfig;
  $fh1->close();

  my $fh2 = IO::File->new();
  $fh2->open(">".$self->NamazuConfigFile);
  print $fh2 $namazuconfig;
  $fh2->close();
}

sub Search {
  my ($self,%args) = @_;
  if ($self->Type eq 'list') {
    # make sure the index has been build reasonably recently
    # skip that for now
    return $self->ListNamazuGrep
      (
       Search => $args{Search},
       Silent => $args{Silent},
      );
  } elsif ($self->Type eq 'fulltext') {
    return $self->FullTextNamazuGrep
      (
       Search => $args{Search},
       Silent => $args{Silent},
      );
  }
}

sub BuildIndex {
  my ($self,%args) = @_;
  my @files;
  if ($self->Type eq 'list') {
    # one is to allow for text search of lists, like file names, in
    # otherwords a locate/apt-file/booktitle search capability
    # need a caching mechanism here
    if ((scalar @{$args{List}}) > $self->SplitSize) {
      # go ahead and split this
      my $i = 0;
      while (scalar @{$args{List}}) {
	my @items = splice @{$args{List}}, 0, $self->SplitSize;
	my $filename = ConcatDir($self->DataDir,$i);
	my $fh = IO::File->new();
	$fh->open(">$filename") or die "cannot open data file\n";
	print $fh join("\n", @items);
	$fh->close;
	push @files, $filename;
	++$i;
      }
    } else {
      my $filename = ConcatDir($self->DataDir,"0");
      my $fh = IO::File->new();
      $fh->open(">$filename") or die "cannot open data file\n";
      print $fh join("\n", @{$args{List}});
      $fh->close;
      push @files, $filename;
    }
  } elsif ($self->Type eq 'fulltext') {
    @files = @{$args{Files}};
  }
  my $fh2 = IO::File->new;
  $fh2->open(">".$self->TargetFile) or die "cannot open target\n";
  print $fh2 join("\n",@files);
  $fh2->close;
  # now build the file for namazu to take as input, then build the index
  # system "cd ".$self->IndexDir." && mknmz -a -F ".$self->TargetFile." -f ".$self->MakeNamazuConfigFile;
  ApproveCommands
    (
     Commands => ["cd ".shell_quote($self->IndexDir)." && mknmz -a -V -F ".shell_quote($self->TargetFile)." -f ".shell_quote($self->MakeNamazuConfigFile)],
    );
}

sub ListNamazuGrep {
  my ($self,%args) = @_;
  my $res = $self->MyNamazuGrep
    (
     Search => $args{Search},
    );
  if ($res->{Success}) {
    my @res;
    foreach my $line (@{$res->{Results}}) {
      chomp $line;
      $line =~ s/^.*://;
      if (! $args{Silent}) {
	print $line."\n";
      }
      push @res, $line;
    }
    return \@res;
  }
}

sub FullTextNamazuGrep {
  my ($self,%args) = @_;
  # namazu -alR 'Drupal' /var/lib/myfrdcsa/codebases/internal/digilib/data/namazu-fulltext/index | while read -d $'\n' it; do to-text "$it" | egrep 'Drupal'; done
  my $res = $self->MyNamazuGrep
    (
     Search => $args{Search},
    );
  if ($res->{Success}) {
    my @res;
    foreach my $line (@{$res->{Results}}) {
      chomp $line;
      if (! $args{Silent}) {
	print $line."\n";
      }
      push @res, $line;
    }
    return \@res;
  }
}

sub MyNamazuGrep {
  my ($self,%args) = @_;
  my $pattern = $args{Search};
  my @indices = ($self->IndexDir);
  my @opts = ();
  my $command = "namazu -alR '$pattern' @indices | xargs egrep @opts '$pattern' /dev/null";
  print $command."\n";
  my @results;
  my $fh = new FileHandle;
  $fh->open("$command |");
  if (defined $fh) {
    while (<$fh>) {
      push @results, $_;
    }
  } else {
    die "nmzgrep: $!";
  }
  return {
	  Success => 1,
	  Results => \@results,
	 };
}

sub MyNamazuGrepOld {
  my ($self,%args) = @_;
  my $commands = "namazu -n 1000 -f /var/lib/myfrdcsa/codebases/internal/boss/scripts/namazu/namazurc ".shell_quote($args{Search});
  my $res = `$commands`;

  $res =~ s/.*Total .+? documents matching your query.\s+//s;
  $res =~ s/\s+Current List: \d+ - \d+\s+//s;

  foreach my $item (split /\n{3,10}/,$res) {
    # print Dumper($item);
    # my @items = $res =~ /^(\d+). (.+?) \(score: (\d+)\)\nAuthor: (.+?)\nDate: (.+)\n(.+?)$(.+) \([\d,]+ bytes\).*/g;
    my ($line_score,$line_author,$line_date,$line_context,$line_file) = split /\n/, $item;
    my ( $id, $head, $score, $author, $date, $context, $filename, $size, );
    if ($line_score =~ /^(\d+)\. (.+?) \(score: (\d+)\)$/) {
      $id = $1;
      $head = $2;
      $score =$3;
    }
    if ($line_author =~ /^Author: (.+)$/) {
      $author = $1;
    }
    if ($line_date =~ /^Date: (.+)$/) {
      $date = $1;
    }
    $context = $line_context;
    if ($line_file =~ /^(.+) \(([\d,]+) bytes\)$/) {
      $filename = $1;
      $size = $2;
    }
    my $structure =
      {
       Id => $id,
       Head => $head,
       Score => $score,
       Author => $author,
       Date => $date,
       Context => $context,
       Filename => $filename,
       Size => $size,
      };
    my $termwidth = 211;
    my $fn = $structure->{Filename};
    my $ct = $structure->{Context};
    my $length = length($fn);
    my $cutoff = $termwidth - $length - 2;
    if ($cutoff < 0) {
      my $substr = substr($fn,0,$termwidth);
      my $wtf = length($substr);
      print Dumper({
		    L => $length,
		    C => $cutoff,
		    F => $fn,
		    C1 => $ct,
		    S => $substr,
		    W => $wtf,
		   }) if 0;
      print $substr."\n";
    } else {
      my $substr = substr($ct,0,$cutoff);
      my $wtf = length($substr);
      print Dumper({
		    L => $length,
		    C => $cutoff,
		    F => $fn,
		    C1 => $ct,
		    S => $substr,
		    W => $wtf,
		   }) if 0;
      print $fn.": ".$substr."\n";
    }
  }
}

$makenamazuconfig = <<EOF1;
# #
# # This is a Namazu configuration file for mknmz.
# #
package conf;  # Don't remove this line!

# ===================================================================

# Administrator's email address

# \$ADDRESS = 'webmaster\@mykerinos.onera';


# ===================================================================

# Regular Expression Patterns



# This pattern specifies HTML suffixes.

# \$HTML_SUFFIX = "html?|[ps]html|html\\.[a-z]{2}";


# This pattern specifies file names which will be targeted.
# NOTE: It can be specified by --allow=regex option.
#       Do NOT use `\$' or `^' anchors.
#       Case-insensitive.

# \$ALLOW_FILE =	".*\\.(?:\$HTML_SUFFIX)|.*\\.txt" . # HTML, plain text
# 		"|.*\\.gz|.*\\.Z|.*\\.bz2" .       # Compressed files
# 		"|.*\\.pdf|.*\\.ps" . 		   # PDF, PostScript
# 		"|.*\\.tex|.*\\.dvi" .   	   # TeX, DVI
# 		"|.*\\.rpm|.*\\.deb" .   	   # RPM, DEB
# 		"|.*\\.doc|.*\\.xls|.*\\.pp[st]" . # Word, Excel, PowerPoint
# 		"|.*\\.docx|.*\\.xlsx|.*\\.pp[st]x" . # MS-OfficeOpenXML Word, Excel, PowerPoint
# 		"|.*\\.vs[dst]|.*\\.v[dst]x" .     # Visio
# 		"|.*\\.j[sabf]w|.*\\.jtd" .        # Ichitaro 4, 5, 6, 7, 8
# 		"|.*\\.sx[widc]" .                 # OpenOffice Writer,Calc,Impress,Draw
# 		"|.*\\.od[tspg]" .                 # OpenOffice2.0
# 		"|.*\\.rtf" .                      # Rich Text Format
# 		"|.*\\.hdml|.*\\.mht" .		   # HDML MHTML
# 		"|.*\\.mp3" .			   # MP3 
# 		"|.*\\.gnumeric" .                 # Gnumeric
# 		"|.*\\.kwd|.*\\.ksp" .             # KWord, KSpread
# 		"|.*\\.kpr|.*\\.flw" .             # KPresenter, Kivio
# 		"|.*\\.eml|\\d+|[-\\w]+\\.[1-9n]"; # Mail/News, man


# This pattern specifies file names which will NOT be targeted.
# NOTE: It can be specified by --deny=regex option.
#       Do NOT use `\$' or `^' anchors.
#       Case-insensitive.

# \$DENY_FILE = ".*\\.(gif|png|jpg|jpeg)|.*\\.tar\\.gz|core|.*\\.bak|.*~|\\..*|\x23.*";


# This pattern specifies DDN(DOS Device Name) which will NOT be targeted.
# NOTE: Only for Windows.
#       Do NOT use `\$' or `^' anchors.
#       Case-insensitive.

# \$DENY_DDN = "con|aux|nul|prn|lpt[1-9]|com[1-9][0-9]?|clock\\$|xmsxxxx0";


# This pattern specifies PATHNAMEs which will NOT be targeted.
# NOTE: Usually specified by --exclude=regex option.

# \$EXCLUDE_PATH = undef;


# This pattern specifies file names which can be omitted 
# in URI.  e.g., 'index.html|index.htm|Default.html'

# NOTE: This is similar to Apache's "DirectoryIndex" directive.

# \$DIRECTORY_INDEX = "";


# This pattern specifies Mail/News's fields in its header which 
# should be searchable.  NOTE: case-insensitive

# \$REMAIN_HEADER = "From|Date|Message-ID";


# This pattern specifies fields which used for field-specified 
# searching.  NOTE: case-insensitive

# \$SEARCH_FIELD = "message-id|subject|from|date|uri|newsgroups|to|summary|size";


# This pattern specifies meta tags which used for field-specified 
# searching.  NOTE: case-insensitive

# \$META_TAGS = "keywords|description";


# This pattern specifies aliases for NMZ.field.* files.
# NOTE: Editing NOT recommended.

# %FIELD_ALIASES = ('title' => 'subject', 'author' => 'from');


# This pattern specifies HTML elements which should be replaced with 
# null string when removing them. Normally, the elements are replaced 
# with a single space character.

# \$NON_SEPARATION_ELEMENTS = 'A|TT|CODE|SAMP|KBD|VAR|B|STRONG|I|EM|CITE|FONT|U|'.
#                        'STRIKE|BIG|SMALL|DFN|ABBR|ACRONYM|Q|SUB|SUP|SPAN|BDO';


# This pattern specifies attribute of a HTML tag which should be 
# searchable.

# \$HTML_ATTRIBUTES = 'ALT|SUMMARY|TITLE';


# ===================================================================

# Critical Numbers



# The max size of files which can be loaded in memory at once.
# If you have much memory, you can increase the value.
# If you have less memory, you can decrease the value.

\$ON_MEMORY_MAX   = 5000000;


# The max file size for indexing. Files larger than this 
# will be ignored.
# NOTE: This value is usually larger than TEXT_SIZE_MAX because 
#       binary-formated files such as PDF, Word are larger.

\$FILE_SIZE_MAX   = 2000000000;


# The max text size for indexing. Files larger than this 
# will be ignored.

\$TEXT_SIZE_MAX   =  2000000000;


# The max length of a word. the word longer than this will be ignored.

\$WORD_LENG_MAX   = 128;



# Weights for HTML elements which are used for term weightning.

# %Weight = 
#     (
#      'html' => {
#          'title'  => 16,
#          'h1'     => 8,
#          'h2'     => 7,
#          'h3'     => 6,
#          'h4'     => 5,
#          'h5'     => 4,
#          'h6'     => 3,
#          'a'      => 4,
#          'strong' => 2,
#          'em'     => 2,
#          'kbd'    => 2,
#          'samp'   => 2,
#          'var'    => 2,
#          'code'   => 2,
#          'cite'   => 2,
#          'abbr'   => 2,
#          'acronym'=> 2,
#          'dfn'    => 2,
#      },
#      'metakey' => 32, # for <meta name="keywords" content="foo bar">
#      'headers' => 8,  # for Mail/News' headers
# );


# The max length of a HTML-tagged string which can be processed for
# term weighting. 
# NOTE: There are not a few people has a bad manner using 
#       <h[1-6]> for changing a font size.

# \$INVALID_LENG = 128; 


# The max length of a field.
# This MUST be smaller than libnamazu.h's BUFSIZE (usually 1024).

# \$MAX_FIELD_LENGTH = 200;


# ===================================================================

# Softwares for handling a Japanese text



# Network Kanji Filter nkf v1.71 or later

# \$NKF = "module_nkf"; 


# KAKASI 2.x or later
# Text::Kakasi 1.05 or later

# \$KAKASI = "module_kakasi -ieuc -oeuc -w";


# ChaSen 2.02 or later (simple wakatigaki)
# Text::ChaSen 1.03

# \$CHASEN = "/usr/bin/chasen -i e -j -F \"\%m \"";


# ChaSen 2.02 or later (with noun words extraction)

# \$CHASEN_NOUN = "/usr/bin/chasen -i e -j -F \"\%m %H\\n\"";


# MeCab

# \$MECAB = "no";


# Default Japanese processer: KAKASI or ChaSen.

# \$WAKATI  = \$KAKASI;


# ===================================================================

# Directories

# \$LIBDIR = "\@PERLLIBDIR\@";
# \$FILTERDIR = "\@FILTERDIR\@";
# \$TEMPLATEDIR = "\@TEMPLATEDIR\@";


1;
EOF1

$namazuconfig = <<EOF2;
# This is a Namazu configuration file for namazu or namazu.cgi.
# #
# #  Originally, this file is named 'namazurc-sample'.  so you should
# #  copy this to 'namazurc' to make the file effective.
# #  see 'doc/ja/manual.html#namazurc' or 'doc/en/manual.html#namazurc'.
# #  
# #  Each item is must be separated by one or more SPACE or TAB characters. 
# #  You can use a double-quoted string for represanting a string which 
# #  contains SPACE or TAB characters like "foo bar baz".


# ##
# ## Index: Specify the default directory.
# ## 
# Index         /var/lib/myfrdcsa/codebases/minor/better-locate/data/namazu


# ##
# ## Template: Set the template directory containing
# ## NMZ.{head,foot,body,tips,result} files.
# ##
# #Template      /usr/local/var/namazu/index


# ##
# ## Replace: Replace TARGET with REPLACEMENT in URIs in search
# ## results.  
# ##
# ## TARGET is specified by Ruby's perl-like regular expressions.  
# ## You can caputure sub-strings in TARGET by surrounding them 
# ## with `(' and `)'and use them later as backreferences by
# ## \\1, \\2, \\3,... \\9.
# ##  
# ## To use meta characters literally such as `*', `+', `?', `|', 
# ## `[', `]', `{', `}', `(', `)', escape them with `\\'.
# ##  
# ## e.g.,
# ##  
# ##    Replace  /home/foo/public_html/   http://www.example.jp/~foo/
# ##    Replace  /home/(.*)/public_html/  http://www.example.jp/\\1/
# ##    Replace  /[Cc]\\|/foo/             http://www.example.jp/
# ##  
# ## If you do not want to do the processing on command line use, 
# ## run namazu with -U option.
# ##
# ## You can specify more than one Replace rules but the only 
# ## first-matched rule are applied. 
# ##
# #Replace       /home/foo/public_html/  http://www.example.jp/~foo/


# ##
# ## Logging: Set OFF to turn off keyword logging to NMZ.slog. 
# ## Default is ON.
# ##
# #Logging       off


# ##
# ## Lang: Set the locale code such as `ja_JP.eucJP', `ja_JP.SJIS', 
# ## `de', etc.  This directive works only if the environment 
# ## variable LANG is not set because the directive is mainly 
# ## intended for CGI use.  On the shell, You can set 
# ## environemtnt variable LANG instead of using the directive.
# ## 
# ## If you set `de' to it, namazu.cgi use 
# ## NMZ.(head|foot|body|tips|results).de for displaying results 
# ## and use a proper message catalog for `de'.
# ##
# #Lang          ja


# ##
# ## Scoring: Set the scoring method "tfidf" or "simple".
# ##
# #Scoring       tfidf


# ##
# ## EmphasisTags: Set the pair of html elements which is used in
# ## keyword emphasizing for search results.
# ##
# #EmphasisTags  "<strong class=\\"keyword\\">"   "</strong>"

# ##
# ## MaxHit: Set the maximum number of documents which can be
# ## handled in query operation.  If documents matching a
# ## query exceed the value, they will be ignored.
# ##
# #MaxHit	10000

# ##
# ## MaxMatch: Set the maximum number of words which can be
# ## handled in regex/prefix/inside/suffix query. If documents
# ## matching a query exceed the value, they will be ignored.
# ##
# #MaxMatch	1000

# ##
# ## ContentType: Set "Content-Type" header output. Specify "charset".
# ##
# ## When you specify English, French, German and Spanish charset
# ##
# #ContentType	"text/html; charset=ISO-8859-1"
# ##
# ## When you specify Polish charset
# ##
# #ContentType	"text/html; charset=ISO-8859-2"
# ##
# ## When you specify Japanese charset by UNIX
# ##
# #ContentType	"text/html; charset=EUC-JP"
# ##
# ## When you specify Japanese charset by Windows
# ##
# #ContentType	"text/html; charset=Shift_JIS"
# ##
# ## If you want to use non-HTML template files, set it suitably.
# ##
# #ContentType	"text/x-hdml; charset=Shift_JIS"

# ##
# ## Charset: "charset" of each "Lang" is defined.
# ## When "charset" is not included in "ContentType", "charset" of default
# ## of each "Lang" is output.
# ## Please define it by "Charset" when you use the language of the
# ## unsupport. (It is necessary to prepare the template and the message
# ## catalog.)
# ##
# #Charset "ja" "EUC-JP"
# ##
# #Charset "ja_JP.SJIS" "Shift_JIS"
# ##
# #Charset "ja_JP.ISO-2022-JP" "ISO-2022-JP"
# ##
# #Charset "fr" "ISO-8859-1"
# ##
# #Charset "de" "ISO-8859-1"
# ##
# #Charset "es" "ISO-8859-1"
# ##
# #Charset "pl" "ISO-8859-2"

# ##
# ## Suicide_Time: namazu.cgi stops the process in 60 seconds by 
# ## default.
# ## (Only UNIX)
# ##
# #Suicide_Time	60

# ##
# ## Regex_Search: Set OFF to turn off regex_search.
# ## Default is ON.
# ##
# #Regex_Search	off
EOF2

1;
