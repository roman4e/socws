#!/bin/bash

base=`dirname $0`
#
source $base/lib/funcs
# DEBUG
set -x
PS4='+${FUNCNAME[-1]:- }@${BASH_SOURCE[-1]##*/}:${LINENO}: '
#

include_module $base/modules/http
include_module $base/modules/route
#
handle_traps EXIT
#
call_module_func http __init

array_echo()
{
	echo -e "key=$2 value=$1<br>"
}

default_handler()
{
	html_raw "
	<div class=\"wrapper\">
	<div>Url=$REQUEST_URI and router=$route</div>
	</div>
	"

	#echo -e "<html><pre>"
	#echo "Url = $url, filename=$filename"
	html_raw "
	<pre>
	$(foreach _HEADER array_echo)
	</pre>
	"
}

parse_request &>/dev/null

#
include_module $base/modules/html
#
html_start

route=${_HEADER[REQUEST_URI]%/*}
route=${route#/}

# check route is present in ./routes/
ls -1 $base/routes|grep $route &>/dev/null
if [ $? -gt 0 ]; then
	error_notfound
	title "404 Not Found"
	html_raw "Path /$route not found"
	#echo -e "<html><head><title>404 Not Found</title></head><body>Path /$module not found</body></html>"
	exit 0
fi

http_ok
end_headers

include_module routes/$route

router_handle $route || default_handler

filename="$base$url"
#html div ([class]="wrapper")
#html c pre
#html c pre "Url = $url, filename=$filename"

# ( set -o posix ; set )

call_module_func $route __shutdown
