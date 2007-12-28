  package Juba::Param::Action
# ****************************
; our $VERSION='0.01'
# ********************
; use strict; use warnings; use utf8
; use base 'Juba::Param'


; __PACKAGE__->mk_accessors
    ( 'action' # stored action map
    )

; sub new
    { my ($self,@args)=@_
    ; my $obj = $self->SUPER::new(@args)

    ; $obj->action({}) unless $obj->action
    ; $obj->validate($obj->action_validator())

    ; $obj->untaint_as('printable') unless $obj->untaint_as
    ; $obj
    }

; sub action_validator
    { my ($obj) = @_
    ; my $name  = $obj->name
    ; return sub 
        { defined $obj->action->{$obj->value} 
        }
    }

; 1

__END__



