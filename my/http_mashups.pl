package my::HTTP;
use strict;
use warnings;
#use Exporter;
#our @ISA=qw(Exporter);
#our @EXPORT=qw(serve_not_allowed serve_not_authorized serve_not_found serve_ok serve_redirect);

my %default_msg=(200=>"OK",404=>"Not Found",405=>"Method Not Allowed",301=>"Moved Permanently");
my %must_have_headers=("Content-Type"=>"text/html; charset=utf-8");
use List::MoreUtils qw(none);

sub serve_not_found
{
	{my($a,$b) = @_;set_content_type($a,$b);}
	http_response(404);
	http_no_body();
}

sub serve_ok
{
	{my($a,$b) = @_;set_content_type($a,$b);}
	http_response(200);
}

sub serve_not_authorized
{
	{my($a,$b) = @_;set_content_type($a,$b);}
	http_response(403);
	http_no_body();
}

sub serve_not_allowed
{
	{my($a,$b) = @_;set_content_type($a,$b);}
	http_response(405);
	http_no_body();
}

sub serve_redirect
{
	{my($a,$b) = @_;set_content_type($a,$b);}
	http_response(301);
	http_redirect(shift||"/");
	http_no_body();
}

sub set_content_type
{
	my $texttype = shift||"";
	my $charset = shift||"UTF-8";
	if ( $texttype eq "" )
	{
		return 0;
	}
	if ( $texttype !~ m{/} )
	{
		$texttype = qq(text/$texttype);
	}
	add_header "Content-Type: $texttype; charset=$charset";
	return 1;
}

sub http_response
{
	my $code = shift;
	my $response_msg = $default_msg{$code}  if defined($default_msg{$code}) || "";
	my $msg = shift||$response_msg;
	our $http_response = "HTTP/1.1 $code $msg";
}

sub check_http_headers
{
	my $hdrs = shift;
	foreach my $k (keys %must_have_headers )
	{
		if ( none { $_ =~ /^${k}/ } @$hdrs )
		{
			if ( ref(\$must_have_headers{$k}) eq "CODE" )
			{
				push(@$hdrs,$k.": ".$must_have_headers{$k}->($hdrs));	# func return default value
			}
			else
			{
				push(@$hdrs,$k.": ".$must_have_headers{$k});
			}
		}
	}
}

1;
