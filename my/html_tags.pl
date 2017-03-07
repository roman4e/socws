#use my::HTTP;
package my::HTML;
use strict;
use warnings;
#use Exporter;
#our @ISA=qw(Exporter);
#our @EXPORT=qw(tag_link_css tag_title tag_script_js tag_script_js_lib);
#%EXPORT_TAGS=('all'=>\@EXPORT);

sub tag_link_css
{
	my $arref=shift;
	my @arr=@$arref;
	return qq(<link href="$arr[1]" rel="stylesheet" />);
}

sub tag_title
{
	my $titleref=shift;
	return qq(<title>$$titleref</title>);
}

sub tag_script_js
{
	my $arref=shift;
	my @arr=@$arref;
	return qq(<script>$arr[1]</script>);
}

sub tag_script_js_lib
{
	my $arref=shift;
	my @arr=@$arref;
	return qq(<script src="$arr[1]"></script>);
}

sub tag_link
{
	my $arref=shift;
	my @arr=@$arref;
	::logit(Dumper(@arr));
	return tag($arr[0],$arr[1],$arr[2]);
}

1;