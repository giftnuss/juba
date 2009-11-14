
; use strict
; use warnings

; package Chest::Global
; use Chest

; our $VERSION='0.0.1'
; our $CHEST

; sub import
    { my ($class)=@_
    ; return if defined $CHEST
    ; $CHEST=new Chest 
    ; for ('insert','insert_always','take','exists','show_chest')
        { eval qq~ sub $_ { shift; \$CHEST->$_(\@_) }~ }
    }

; 1

__END__
