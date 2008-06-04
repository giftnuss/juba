  package DBIx::Define::Autoload
# ******************************
; our $VERSION='0.01'
# *******************

# this is a placholder for a more specialized and flexible
# solution.

; our $AUTOLOAD
   
; sub AUTOLOAD
    { my $sub = $AUTOLOAD
    ; $sub =~ s/.*:://
    ; if( my $type = DBIx::Define::Type->get_type_object($sub,{@_}) )
        { return $type
	}
    }


; 1
  
__END__
  
