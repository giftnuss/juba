  package SKNPP
# *************
; use strict; use warnings

; use File::Basename ('basename','dirname')

; my $place
; BEGIN
  { foreach my $mod (keys %INC)
      { do { $place = dirname($mod) ; last } if basename($mod,'.pm') eq 'SKNPP' 
      }
  }

; use lib "$place/p5-ho-class/lib"
; use lib "$place/p5-ho-common/lib"
  
; 1
  
__END__
  
