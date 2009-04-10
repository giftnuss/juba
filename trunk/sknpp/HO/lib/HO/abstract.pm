  package HO::abstract
# *********************
; our $VERSION='0.01'
# ********************
; use strict; use warnings

; use Package::Subroutine ()
; use Carp ()

; our $METHOD_DIE = sub
    { my ($method) = @_
    ; return sub
        { if(ref($_[0]))
            { Carp::croak("Abstract method '$method' called for object of class " . ref($_[0]).'.')
            }
          else
            { Carp::croak("Abstract method '$method' called for class $_[0].")
            }
        }
    }
	
; { our $target

  ; sub abstract_method
      { my @methods = @_
	  ; local $target = $target
	  
      ; foreach my $method (@methods)
          { install Package::Subroutine 
		      $target => $method => $METHOD_DIE->($method)
          }
	  }
    
  ; sub import
      { my ($self,$action,@params) = @_
	  ; return unless defined $action
	  ; local $target = caller
	
	  ; my $perform = { 'method' => \&abstract_method }->{$action}
	  ; die "Unknown action '$action' in use of HO::abstract." unless $perform
	
	  ; $perform->($target,@params)
      }
  }
    
; 1

__END__


