
; use strict
; use warnings

; package HO::Exporter

#; BEGIN { $Exporter::Verbose=1 } 

; our $VERSION='0.0.2'

; use Exporter
; use Carp
; our @ISA=qw(Exporter);

; our %defined

; sub create_tag
    { my ($class,$pack,$base,$tag)=@_
    ; return if $defined{$pack}
    ; eval qq~ package $pack; our \@ISA = qw($base)
             ; sub new { shift()->SUPER::new("$tag",\@_) }
             ~
    ; $defined{$pack}++
    } 

; sub register
   { my $pack=shift
   ; my $export=shift
   ; carp "@_" if 0+@_%2 != 0
   ; my %func=@_
   ; while( my ($func,$class)=each(%func) )
      { eval qq~package $pack; sub $func { $class->new(\@_) }~
          unless $pack->can($func)
      ; @{$export}=($func)
      ; $pack->export_to_level(2,$func)
      }
   }
 
; 1
 
__END__

=head1 NAME

HO::Exporter - Extension to export HO constructor functions
