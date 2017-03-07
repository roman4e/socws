use strict;
use warnings;

use my::HTML qw(:all);

my::HTTP::serve_ok;

add_head "title","API health";
add_head "title","ok";
add_head "css","/static/main.css";

body qq(<div><h1>API Health Status</h1><div class="api-status">ok</div>);

# body (["div","",{class=>"wrapper"}]
# 	,[">h1","API health status"]
# 	,["+div","ok",{class=>"api-status"]);

# ["<(div:class=wrapper)+div","window",{class=>"window"}] -- adds div as a sibling to div with class=wrapper in parent tree if found it

#$my::HTTP::http_body =
#$my::HTTP::http_body = "<!DOCTYPE><html>ok</html>";
1;