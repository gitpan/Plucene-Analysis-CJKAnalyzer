package Plucene::Analysis::CJKAnalyzer;

$Plucene::Analysis::CJKAnalyzer::VERSION = '0.02';


=head1 NAME 

Plucene::Analysis::CJKAnalyzer - Analyzer for CJK texts

=head1 SYNOPSIS

	# isa Plucene::Analysis::Analyzer

	my Plucene::Analysis::CJKAnalyzer $wt 
		= Plucene::Analysis::CJKAnalyzer->new(@args);
		
=head1 DESCRIPTION

This is a text analyzer for analyzing CJK texts. L<Plucene> does not support
CJK texts natively. This module encodes terms in L<MIME::Base64> format to get
around this problem. Texts are assumbed to be in UTF-8 encoding.

See L<t/cjk.t> for more details.

=head1 METHODS

=cut

use strict;
#use warnings;

use base 'Plucene::Analysis::Analyzer';

=head2 tokenstream

	my Plucene::Analysis::CJKAnalyzer Plucene::Analysis::ChineseAnalyzer->new(@args);

Creates a TokenStream which tokenizes all the text in the provided Reader.

=cut

use Plucene::Analysis::CJKTokenizer;
sub tokenstream {
	my $self = shift;
	return Plucene::Analysis::CJKTokenizer->new(@_);
}

=head1 SEE ALSO

L<Plucene>

L<MIME::Base64>

L<Plucene::Analysis::CJKTokenizer>

=head1 COPYRIGHT

Copyright (C) 2006 by Yung-chung Lin (a.k.a. xern) <xern@cpan.org>
       
This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself
                     
=cut                     

1;
