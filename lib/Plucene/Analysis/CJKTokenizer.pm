package Plucene::Analysis::CJKTokenizer;


=head1 NAME 

Plucene::Analysis::CJKTokenizer - Tokenizer for CJK texts


=head1 SYNOPSIS

	# isa Plucene::Analysis::Tokenizer

	my $next = $chartokenizer->next;
	
=head1 DESCRIPTION

This module tokenizes CJK texts. It creates uni-gram tokens from CJK texts.
(See also L</PROBLEMS>) Because I understand not much of Japanese and
Korean, I rudely apply this method to them. Patches are always welcome.

=head1 METHODS

=cut

use strict;
use warnings;

use Plucene::Analysis::Token;

use base 'Plucene::Analysis::Tokenizer';

sub token_re { //o }
sub normalize { @_ }

=head2 next

	my $next = $chartokenizer->next;

This will return the next token in the string, or undef at the end 
of the string.
	
=cut

use utf8;
use Encode;
use YAML;
use MIME::Base64;
use encoding 'utf8';

=head1 GLOBAL VARIABLE

Here is one pattern variable that you can modify to customize your
tokenizer for a specific collection.

=head2 $InCJK

Default pattern for CJK characters.

Default value is 

qr(
    \p{InCJKUnifiedIdeographs} |
    \p{InCJKUnifiedIdeographsExtensionA} |
    \p{InCJKUnifiedIdeographsExtensionB} |

    \p{InCJKCompatibilityForms} |
    \p{InCJKCompatibilityIdeographs} |
    \p{InCJKCompatibilityIdeographsSupplement} |

    \p{InCJKRadicalsSupplement} |
    \p{InCJKSymbolsAndPunctuation} |
    
    \p{InHiragana} |
    \p{InKatakana} |
    \p{InKatakanaPhoneticExtensions} |
    
    \p{InHangulCompatibilityJamo} |
    \p{InHangulJamo} |
    \p{InHangulSyllables}
   )x;


=cut

our $InCJK
   =
    qr(
    \p{InCJKUnifiedIdeographs} |
    \p{InCJKUnifiedIdeographsExtensionA} |
    \p{InCJKUnifiedIdeographsExtensionB} |

    \p{InCJKCompatibilityForms} |
    \p{InCJKCompatibilityIdeographs} |
    \p{InCJKCompatibilityIdeographsSupplement} |

    \p{InCJKRadicalsSupplement} |
    \p{InCJKSymbolsAndPunctuation} |
    
    \p{InHiragana} |
    \p{InKatakana} |
    \p{InKatakanaPhoneticExtensions} |
    
    \p{InHangulCompatibilityJamo} |
    \p{InHangulJamo} |
    \p{InHangulSyllables}
   )x;


sub scantext {
    my $self = shift;
    my $text = shift || return ;

    my $word = $self->{word};
    Encode::_utf8_on($text);
    my @tok;

    # Extract alphanumeric string
    # I assume texts that are without [aiueo0-9] unworth of indexing
    if($text =~ /[aiueo0-9]/io){
      while($text =~ /([\p{Latin}\p{Number}]+)/go){
          my $tok = lc $1;
#          print ">> $tok $-[1] $+[1]\n";
          push @tok, [ $tok, $-[1], $+[1] ];
      }
    }


    if($text =~ /(?:$InCJK)/o){
	# Extract unigrams
        while($text =~ /($InCJK)/go){
	  my $t = $1;
	  next unless length($t) == 1;
#	  print $t, ' ';
	  push @tok, [$t, $-[1], $+[1]];
        }

	# Extract bigrams
        # Weird. Not working.... ><
        # Skip this for the time being.
#        for (my $i=0; $i<$#t; $i++){
#            my $t = $t[$i]->[0].$t[$i+1]->[0];
#	    print $t,"\n";
#            push @tok, [ $t, $t[$i]->[1], $t[$i+1]->[2] ];
#        }
#	@tok = (@tok, @t);
    }
    my %h;
    push @$word,
      grep{!$h{$_->[0]}++} # Remove duplicates
	  map{
	    chomp$_->[0];
#	    print $_->[0]. ' ';
	    Encode::_utf8_off($_->[0]);
	    $_->[0] = encode_base64($_->[0], '');
#	    print "TOK:",  $_->[0],"\n";
	    $_
	  }
	  grep{$_->[0]}
	  grep{ref$_}
	    @tok;

#    print '<<<';
#    use YAML;
#    print YAML::Dump $word;
#    print '>>>';
}

sub next {
  my $self = shift;
  my $fh   = $self->{reader};
  if (!defined $self->{buffer} or !length $self->{buffer}) {
    $self->{start} = tell($fh);
    $self->{buffer} .= <$fh>;
  }

  if($self->{buffer}){
    $self->{word} = [] unless ref $self->{word};
    $self->{buffer} =~ s/\r?\n/ /go; # strip newlines
#    print "Scanning ($self->{buffer})\n";
    $self->scantext($self->{buffer});
#    print "Dumping ...\n";
#    print Dump $self->{word};
    $self->{buffer} = undef; # This step is crucial. No forgetting
  }
  if(my $tok = shift @{$self->{word}}){
    Plucene::Analysis::Token
                ->new(
                    text => $tok->[0],
                    start => $tok->[1],
                    end => $tok->[2],);
  }
}

=head1 PROBLEMS

Currently, I tested bigram tokens, but it keeps failing. Snipped for the current release.

Speed is another issue.

=head1 SEE ALSO

L<Plucene>

L<Plucene::Analysis::CJKAnalyzer>

L<MIME::Base64>


=head1 COPYRIGHT

Copyright (C) 2006 by Yung-chung Lin (a.k.a. xern) <xern@cpan.org>
       
This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself
                     
=cut                     


1;

 