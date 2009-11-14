
; use strict
; use warnings

; package HO::HTML::Document::Type
; use HO::Tag
; use base 'HO::Tag::Single'
; use Carp

; our $VERSION='0.2.0'

; sub _bopentag () { '<!' } # inline
; sub _closetag () { '>'  } # inline

; our %list=
   ( strict       => [ '','strict.dtd' ]
   , transitional => [ ' Transitional','loose.dtd' ]
   , frameset     => [ ' Frameset','frameset.dtd' ]
   )

; sub import
   { my ($class,$d)=@_
   ; our $default= $d || 'transitional'
   ; our %list
   ; croak "Undefined document type $d" unless $list{$default}
   }
   
sub new
  { my ($class,$type,@arg) = @_
  ; our (%list,$default)
  ; $type = $default unless $type && $list{$type}
  
  ; my $tag="DOCTYPE HTML PUBLIC"
  ; my $self=$class->SUPER::new($tag,@arg)
  ; $self->type($type)
  }
  
; sub get_attributes
  { my $self=shift
  ; our %list
  ; my $str=' "-//W3C//DTD HTML 4.01%s//EN" "http://www.w3.org/TR/html4/%s"'
  ; my $type=$self->_attributes->{'type'}
  ; sprintf($str,@{$list{$type}})
  }

=head1 NAME

HO::HTML::Document::Type

=head1 Beschreibung

Die Klasse enthält die gebräuchlichsten Dokumententypangaben.
Sie sind der SelfHTML-Dokumentation v8.0 von Stefan Münz entnommen;

        my $dc = new HO::Doctype( 'transitional' );


=cut

1;
