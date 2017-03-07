package my::HTTP;

use strict;
use warnings;

# our (@ISA, @EXPORT_OK, @EXPORT_TAGS);
# BEGIN {
	use Exporter;
	#use vars q(@ISA @EXPORT_OK %EXPORT_TAGS @EXPORT);
	our @ISA=qw(Exporter);
	#our @EXPORT=qw(accept_request %request %get %post $request_uri);
	our @EXPORT_OK=qw(accept_request make_response
		%request %get %post $request_uri %data);
	our %EXPORT_TAGS=('all'=>\@EXPORT_OK,'funcs'=>[qw(accept_request make_response)],'req'=>[qw(%request $request_uri)],'data'=>[qw(%get %post)]);
# }
# Await requests and handle them as they arrive
our %request = ();
our %data = ();
our %get = ();
our %post = ();
our $request_uri = "";
my  @passthru = ();

our $http_body = "<!DOCTYPE>";
our @http_headers = ();
our $http_response = "";

require "my/http_funcs.pl";
require "my/http_mashups.pl";

sub accept_request
{
	my $client = $_[0];

	local $/ = "\r\n";
	# for http parse all headers until empty string
	while (<$client>) {
		chomp; # Main http request
		if (/\s*(\w+)\s*([^\s]+)\s*HTTP\/(\d.\d)/) {
			$request{METHOD} = uc $1;
			$request{URL} = $2;
			$request_uri = $2;
			$request{HTTP_VERSION} = $3;

			$request_uri =~ /^[\/]?(.*?)(?:[?]|$)/;
			{
				my @d = split('/',$1);
				$request{PARTS} = \@d || ["index"];
			}

		} # Standard headers
		elsif (/:/) {
			(my $type, my $val) = split /:/, $_, 2;
			$type =~ s/^\s+//;
			$type =~ tr/[-]/[_]/;
			foreach ($type, $val) {
					s/^\s+//;
					s/\s+$//;
			}
			$request{lc $type} = $val;
		} # POST data
		elsif (/^$/) {
			read($client, $request{CONTENT}, $request{content_length})
				if defined $request{content_length};
			last;
		}
	}
	parse_request_data();
	return;
}

sub parse_request_get_data
{
	# get request params are always present
	if ($request{URL} =~ /(.*)\?(.*)/)
	{
		$request{URL} = $1;
		%get = parse_form($2);
	}
	else
	{
		%get = ();
	}
	return;
}

sub parse_request_data
{
	parse_request_get_data;

	if ($request{METHOD} eq 'POST')
	{
		%post = parse_form($request{CONTENT});
	}
	return;
}

sub add_header
{
	push(@http_headers,@_);
}

sub passthru
{
	push(@passthru,@_);
}

sub make_response
{
	my $body = shift || $http_body;
	local $\="\n";
	print $http_response;
	my $do_passthru=0;

	if ( scalar @passthru > 0 )
	{
		$do_passthru = 1;
	}
	else
	{
		push(@http_headers,"Content-Length: ".(length $body));
	}

	check_http_headers(\@http_headers);
	print join($/,@http_headers);
	print "";

	if ( $do_passthru )
	{
		local $| = 1;
		my $data;
		open(my $f, "<", $passthru[0]);

		while ( read($f,$data,16384) )
		{
			print $data;
		}
		close($f);
	}
	else
	{
		print $body;
	}
}


1;