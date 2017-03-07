#!/usr/bin/perl -w
use strict;
use warnings;
use lib "./";
use my::HTTP qw(:funcs :req);
use File::Basename;

STDIN->blocking(0); # main thing do not change

my $DOCUMENT_ROOT=dirname(__FILE__);
#$DOCUMENT_ROOT=~ s|/\w+$||; # no ending /

handle_stdin();
flush_logit();

our @loglines=();

sub server_route
{
	my $client = $_[0];
	#my $localfile = $DOCUMENT_ROOT.$request_uri;

	my $route_file=$DOCUMENT_ROOT."/my/routes/".(lc $request{PARTS}[0]).".pl";

	if ( defined($request{PARTS}[0]) && -f $route_file )
	{
		require $route_file;
	}
	else
	{
		my::HTTP::serve_not_found();
	}
	use my::HTML;

	make_response my::HTML::generate();
	return;
}

sub std_flow
{
	my $client = $_[0];
	my $out = $_[1];
	#-------- Read Request ---------------
		accept_request $client;
	#-------- SORT OUT METHOD  ---------------
		# parse_request_data;
	#------- Serve file ----------------------
		server_route $out;
	# ----------- Close Connection and loop ------------------
	return;
}

sub handle_socket
{
	my $server=$_[0];
	while (my $client = $server->accept())
	{
		$client->autoflush(1);
		std_flow $client,$client;
		close $client;
	}
	return;
}

sub handle_stdin
{
	my $client = \*STDIN;
	my $out = \*STDOUT;

	std_flow $client,$out;
	return;
}

sub logit
{
	push(@loglines,@_);
}

sub flush_logit {
	print join("\n",@loglines);
}