package Text::Overflow;

use utf8;
use strict;
use warnings;

our $VERSION = '0.01';

use Exporter::Lite;
use Unicode::EastAsianWidth;

our @EXPORT_OK = qw(
	vlength
	trim
	vtrim
	clip
	ellipsis
);

sub vlength ($) { ## no critic
	my ($string) = @_;
	my $ret = 0;
	local $_ = $string;
	while (/(?:(\p{InFullwidth}+)|(\p{InHalfwidth}+))/g) {
		$ret += $1 ? length($1) * 2 : length($2);
	}
	$ret;
}

sub trim {
	my ($string, $length, $delim) = @_;
	return $string if length $string <= $length;
	substr($string, 0, $length - length($delim)) . $delim;
}

sub vtrim {
	my ($string, $length, $delim) = @_;
	return $string if vlength $string <= $length;

	my $ret   = "";
	my $limit = $length - vlength($delim);

	local $_ = $string;
	while (/(?:(\p{InFullwidth})|(\p{InHalfwidth}))/g) {
		my $n = $1 ? length($1) * 2 : length($2);
		last if $limit < $n;
		$ret .= $1 || $2;
		$limit -= $n;
	}
	$ret . $delim;
}

sub clip {
	my ($string, $length) = @_;
	vtrim($string, $length, '');
}

sub ellipsis {
	my ($string, $length) = @_;
	vtrim($string, $length, '…');
}

1;
__END__

=encoding utf8

=head1 NAME

Text::Overflow - 

=head1 SYNOPSIS

  use Text::Overflow qw(ellipsis clip);

  clip('1234567890', 6);
  #=> '123456';

  clip('１２３４５６７８９０', 6);
  #=> '１２３';

  ellipsis('1234567890', 6);
  #=> '12345…';

  ellipsis('１２３４５６７８９０', 6);
  #=> '１２…';


=head1 DESCRIPTION

Text::Overflow is for clipping text for a width

=head1 AUTHOR

cho45 E<lt>cho45@lowreal.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
