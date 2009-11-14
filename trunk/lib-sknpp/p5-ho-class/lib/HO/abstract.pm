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

; our $CLASS_DIE = sub
    { my ($class) = @_
    ; return sub
        { my $instanceof = ref($_[0])
        ; if($instanceof eq $class)
            { Carp::croak("Abstract class '$class' should not be instatiated.")
            }
          else
            { Carp::croak("Class '$instanceof' should overwrite method init from abstract class '$class'.")
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

  ; sub abstract_class
      { my (@classes) = @_ ? @_ : ($target)
      ; foreach my $class (@classes)
          { install Package::Subroutine
                     $class => 'init' => $CLASS_DIE->($class)
          } 
      }

  ; sub import
      { my ($self,$action,@params) = @_
      ; return unless defined $action
      ; local $target = caller

      ; my $perform = 
              { 'method' => \&abstract_method 
              , 'class' => \&abstract_class
              }->{$action}
      ; die "Unknown action '$action' in use of HO::abstract." unless $perform

      ; $perform->($target,@params)
      }
  }

; 1

__END__

=head1 NAME

HO::abstract - helper for abstract classes and methods

=head1 SYNOPSIS

   package Class::Is::Abstract;

   use HO::abstract class =>
