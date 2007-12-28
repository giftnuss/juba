  package Juba::Param
# *******************
; our $VERSION='0.01'
# *******************

; use strict; use warnings

; use base 'Class::Accessor::Fast'

; use Juba::Param::Action
; use Juba::Param::Data



; __PACKAGE__->mk_accessors
    ( 'name'       # the silly name
    , 'value'      # untainted value
    , 'raw_value'  # 
    , 'untaint_as' # what should be used to untaint the data
    , 'validate'   # optional coderef for additional checks
    , 'required'   # boolean
    , 'error'
    )

#; sub new { my $self=shift;print caller(); $self->SUPER::new(@_) } 

; sub untaint
    { my ($obj,$handler) = @_
    ; my ($untaint)

    ; $obj->raw_value($handler->raw_data_value($obj->name))

    ; if($untaint = $obj->untaint_as)
        { $untaint = "-as_${untaint}"
        ; $obj->value( $handler->extract( $untaint => $obj->name ) );
        ; $obj->error( $handler->error )
        }
    }

; sub is_valid 
    { my ($obj,@args) = @_
    ; if(my $code = $obj->validate)
        { return $code->($obj,@args) 
        }
    ; 1
    }

; 1

__END__

=head1 NAME

Juba::Param

=head1 SYNOPSYS
