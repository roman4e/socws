use my::HTTP;
package my::HTTP;
use strict;
use warnings;

our $http_body;

sub print
{
}

sub print_header
{
	local $/="\r\n";
}

sub print_headers_end
{
	print "\r\n\r\n";
}

sub flush_headers
{

}

sub flush_body
{

}

sub http_no_body
{
	undef $http_body; $http_body = "";
}

1;