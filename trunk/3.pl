; use strict; use warnings; use utf8

; BEGIN 
    { my $here = [caller(0)]->[1] =~ /(.*)\// && $1 || '.'
    ; eval "use lib '$here','$here/lib-cpan'"
    }

; use Juba::Application
; use CGI::Carp 'fatalsToBrowser'

; BEGIN { print "#<pre>\n" }

; use Apache::Test qw(-withtestmore)

; BEGIN  
    { plan tests => 2
    ; Test::More::use_ok($_) for qw/HO Package::Subroutine/ 
    }

; print "#</pre>\n"

