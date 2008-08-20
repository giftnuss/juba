  use strict; use warnings
  ; use Test::More tests => 4
  
; BEGIN
    { use_ok('HO::HTML')
    }
    
; my $tag = HO::HTML::factory('a')
; is("$tag","<a></a>");
    
; $tag = HO::HTML::factory('A')
; is("$tag","<a></a>");

; $tag = HO::HTML::factory('Img')
; is("$tag","<img >");


    