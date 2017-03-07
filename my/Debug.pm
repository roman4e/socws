package my::Debug;
use strict;
use warnings;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);
@ISA=qw(Exporter);
@EXPORT = qw(logit);

our $method = "print";
our $stream = *STDOUT;

my %meth_table = (print => \&method_print_priv);

sub logit
{
	my $arg1=shift||"<nothing to log>";
	if ( exists($meth_table{$method}) )
	{
		$meth_table{$method}->($arg1) if defined(*::SCRIPTDEBUG);
	}
}

sub set_method
{
	$method = shift;
}

sub set_stream
{
	$stream = shift||*STDOUT;
}

sub method_print_priv
{
	print $stream $_[0],"\n";
}