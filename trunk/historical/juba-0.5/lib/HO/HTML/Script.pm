
; use strict
; use warnings

; package HO::HTML::Script

; use HO::Tag
; use HO::Exporter
; use base ('HO::Tag','HO::Exporter');

; our $VERSION='0.0.2';
; our @EXPORT

; sub import
   { my $class=shift
   ; my %p=( namespace => '', functional => 0, @_)
   ; my $ns=$p{namespace}; $ns.='::' if $ns
   
   ; my $t='Script'
   ; my $pack=$ns.$t
   ; $class->create_tag($pack,'HO::HTML::Script',lc $t)
   ; $class->register( \@EXPORT, $t, $pack ) if $p{functional}
   
   ; $t='Noscript'
   ; $pack=$ns.$t
   ; $class->create_tag($pack,'HO::Tag::Double',lc $t)
   ; $class->register( \@EXPORT, $t, $pack ) if $p{functional}
   }

; sub new
   { my $class=shift
   ; $class->SUPER::new(shift, "<!--//\n" , @_ )
           ->type('text/javascript');
   }

; sub src
   { my $obj=shift
   ; $obj->set_attribute('src',shift);
   ; splice( @{$obj->_thread},1,1);
   ; $obj
   }

; sub get
   { my $self=shift
   ; if( exists $self->_attributes->{'src'} )
      { (bless $self, 'HO::Tag::Single')->get() }
     else
      {	$self->insert("\n//-->")
      ; (bless $self, 'HO::Tag::Double')->get()
      }
   }
   
; 1

__END__
   
