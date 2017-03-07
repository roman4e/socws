Package HTTP;

use strict;
use warnings;

sub parse_form
{
	my $data = $_[0];
	my %data;
	foreach (split /&/, $data)
	{
		my ($key, $val) = split /=/;
		$val =~ s/\+/ /g;
		$val =~ s/%(..)/chr(hex($1))/eg;
		$data{$key} = $val;
	}
	return %data;
}

