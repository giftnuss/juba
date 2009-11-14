
; use strict
; use warnings

; package Chest
; use Carp

; our $VERSION='0.0.8'

; sub new
    { my ($class)=@_
    ; $class = ref $class if ref $class
    ; bless {} , $class
    }

; sub insert
    { my ($self,$key,$sub,@args)=@_
    ; $self->{$key}=&$sub( $self , @args )
        unless $self->exists($key)
    }

; sub insert_always
    { my ($self,$key,$sub,@args)=@_
    ; $self->{$key}=&$sub( $self , @args )
    }

; sub exists
    { my ($self,$key)=@_
    ; CORE::exists $self->{$key}
    }

; sub take
    { my ($self,$key,@par)=@_
    ; unless( $self->exists($key) )
        { carp "$key isn't in the chest."
        ; return 
        }			   
    ; &{$self->{$key}}(@par);
    }
    
; sub show_chest
    { my $self=shift
    ; print STDERR "\n *** CHEST ***"
	  ; foreach ( keys %{ $self->{'chest'}} )
        { print STDERR "\n$_" }
    ; print "\n"
    }

; 1

__END__
