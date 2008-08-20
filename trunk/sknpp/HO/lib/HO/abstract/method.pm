  package HO::abstract::method
# ****************************
; our $VERSION='0.01'
# *******************

; use Package::Subroutine
; use Carp ()

; our $DIE = sub
    { my ($method) = @_
    ; return sub
        { my @call = caller(1)
        ; if(ref($_[0]))
            { Carp::croak("Abstract method '$method' called for object of class " . ref($_[0]))
            }
          else
            { Carp::croak("Abstract method '$method' called for class $_[0].")
            }
        }
    }
    
; sub import
    { my ($self,@methods) = @_
    ; my $target = caller
    ; foreach my $method (@methods)
        { install Package::Subroutine $target => $method => $DIE->($method)
        }
    }
    
; 1

__END__


