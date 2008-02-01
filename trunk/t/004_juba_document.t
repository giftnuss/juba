  use t::Test::Juba
  ; use Test::More tests => 1
  
  ; BEGIN { require_ok('Juba::Document') }
  
  ; use strict
  ; { package T::doc
    ; use Juba::Document
  
    ; 
    ; dc.title("juba")
    
    }
    
  ; use Data::Dumper
  ; print Dumper($T::doc::Document{'_'})
    
