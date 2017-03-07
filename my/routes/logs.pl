use strict;
use warnings;

use my::HTML qw(:all);

head "title","Logs";

my $arcprefix="/var/lib/nginx-gather/arc";

if ( defined($request{PARTS}->[1]) )
{
	my $part1 = $request{PARTS}->[1];
	if ( $part1 eq "latest" )
		{ 	latest(); }
	elsif ( $part1 =~ /^\d+$/ )
		{ 	my $a=\@{$request{PARTS}};::logit(@$a);my $p=join("/",@{$a}[1..$#{$a}]);getlog($p); }
	else
		{ anything_wrong(); }

}
else
{
	logs_api();
}

# body qq(ok);

sub latest
{
	my::HTTP::serve_ok "xml";
	my::HTML::set_output_xml;
	#my::HTTP::http_xml;
	body qq(<links></links>);
	body qq(<description>Latest logs</description><files>);
	open(my $ziplist,"<","/var/lib/nginx-gather/arc/latest");
	while ( <$ziplist> )
	{
		chomp;
		m|^(.*?)/([^/]+?),|;
		body "<file size=\"".(-s $arcprefix."/$1/$2")."\" path=\"$1/$2\">$2</file>";
	}
	body "</files>";
}

sub getlog
{
	my $reqlog = $_[0];
	# ::logit(@_);
	my $arclogpath=$arcprefix."/".$reqlog;
	if ( ! -r $arclogpath )
	{
		my::HTTP::serve_not_found;
		body "requested file $reqlog not found";
		return 0;
	}
	my::HTTP::serve_ok "xml";
	#my::HTTP::head("Content-Type: binary/octet-stream");
	my $fsize=-s $arclogpath;
	# http://loghost.local/logs/2016/31/218/10/logrec.local_post_218_d2aabce17553fde2971712ac0fd7d769.zip
	$reqlog =~ m|/([^/]+)$|;
	::logit($arclogpath);
	my::HTTP::head("Content-Disposition: attachment; filename=$1; size=$fsize");
	my::HTTP::passthru($arclogpath);
	# body "file contents";
	return 0;
}

sub anything_wrong
{
	my::HTTP::serve_not_found;
}

sub logs_api
{
	my::HTTP::serve_ok "xml";
	my::HTML::set_output_xml;
	body qq(<links><link rel="latest" allowed-methods="get">latest</link><link rel="search" allowed-methods="post">search</link><link rel="download" allowed-methods="get">%{s:0000/00/000/00/*.zip}</link></links>);
}

1;