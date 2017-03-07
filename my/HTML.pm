package my::HTML;
use strict;
use warnings;

use Exporter;
our @ISA=qw(Exporter);
our @EXPORT_OK=qw(tag close_tag head body);
our %EXPORT_TAGS=('all'=>\@EXPORT_OK);

use Data::Dumper;

require "my/html_tags.pl";

our @body=();
our $headers_count=0;
our $gentype = 0;	# 0 = html, 1 = xml
# my @headers=("<title>");
my %sheaders=(title=>"",css=>[], jslib=>[], js=>[], meta=>[], link=>[], other=>[]);
my %sheader_tag=(title=>"title", css=>"link", js=>"script", meta=>"meta",link=>"link");
my %sheader_map=(css=>\&tag_link_css,jslib=>\&tag_script_js_lib,title=>\&tag_title,js=>\&tag_script_js,link=>\&tag_link);

use List::MoreUtils qw(none any);

my @singles = qw(meta img br hr link param);

sub tag
{
	my $name   = lc shift;
	my $value  = shift || "";
	my $attrs0 = shift || {};
	my %attrs  = %$attrs0;
::logit (" tag=$name val=$value at=$attrs0 ".(%attrs));
	my $is_single = any { $_ eq $name } @singles;
::logit (" single=$is_single $name ");
	# my $is_single = reduce { $a || $code->(local $_ = $b) } 0, @singles;
	my $res = "<$name";
	$res .= " ".join(" ",map { $_."=".qq("$attrs{$_}") } keys %attrs ) if scalar %attrs > 0;
	$res .= ">$value</$name>" if !$is_single;
	$res .= ">" if $is_single;
	return $res;
}

sub close_tag
{
	my $upto = shift||1;
}

sub head
{
	my $tag=lc shift;
	my $value=shift||"";
	my $attrref = shift||{};
	our $headers_count++;

	if ( defined($sheaders{$tag} ) )
	{
		#print "adding header $tag with $value ref=".ref(\$sheaders{$tag})."; ";
		if ( ref(\$sheaders{$tag}) eq "SCALAR" )
		{
			$sheaders{$tag} = $value;
		}
		elsif ( ref($sheaders{$tag}) eq "ARRAY" )
		{
			::logit ( Dumper([$tag,$value,$attrref]) );
			push(@{$sheaders{$tag}},[$tag,$value,$attrref]);
		}
	}
	else
	{
		push(@{$sheaders{other}},[$tag,$value,$attrref]);
	}
	return;
}

sub body
{
	foreach (@_)
	{
		push(@body,$_) if ref(\$_) eq "SCALAR";
	}
	return;
}


sub from_groups
{
	my ($hashref,$mapref) = @_;
	my %hash = %$hashref;
	my %funcmap = %$mapref;
	my $html="";

	# traverse each group
	foreach my $k ( keys %hash )
	{
		# each group can be array or simple string
		my $sub = sub { return $_; };
		my $func=defined($funcmap{$k}) ? $funcmap{$k} : $sub;
		my $item_type = ref($hash{$k});
		my $item_type_ref = ref(\$hash{$k});

		::logit( "\nusing key=$k and func=$func and '$item_type' '$item_type_ref';");

		if ( $item_type_ref eq "SCALAR" )
		{
			$html .= $func->(\$hash{$k});
		}
		elsif ( $item_type_ref eq "REF" )
		{
			if ( $item_type eq "ARRAY" )
			{
				foreach my $item (@{$hash{$k}})
				{
					::logit(Dumper($item) );
					$html .= $func->($item);
				}
			}
		}
	}
	return $html;
}

sub set_output_html
{
	$gentype = 0;
}

sub set_output_xml
{
	$gentype = 1;
}

sub generate
{
	if ( $gentype == 0 )
	{
		return generate_html();
	}
	elsif ( $gentype == 1 )
	{
		return generate_xml();
	}
	else
	{
		return "generation type error";
	}

}

sub generate_html
{
	my $html = "<!DOCTYPE>\n<html>\n";
	#use Data::Dumper;

	$html .= "<head>" if $headers_count;
	$html .= from_groups \%sheaders, \%sheader_map;
	$html .= "</head>" if $headers_count;

	$html .= "<body>\n";
	$html .= join "\n",@body;
	$html .= "</body>\n";

	$html .= "</html>\n";
	return $html;
}

sub generate_xml
{
	my $html = qq(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n);
	$html .= qq(<manufactura>);
	$html .= join "\n",@body;
	$html .= qq(</manufactura>\n);
}
1;