
; use strict
; use warnings

; package HO::HTML::Style

; use HO::Tag
; use HO::Exporter
; use base ('HO::Tag','HO::Exporter')

; our $VERSION='0.0.2'
; our @EXPORT

; sub import
  { my $class=shift
  ; my %p=( namespace => '', functional => 0, @_)
  ; my $ns=$p{namespace}; $ns.='::' if $ns
   
  ; my $t='Style'
  ; my $pack=$ns.$t
  ; $class->create_tag($pack,$class,lc $t)
  ; $class->register( \@EXPORT, $t, $pack ) if $p{functional}
  }
  
; sub new
  { my $class=shift
  ; $class->SUPER::new(shift(),"\n<!--\n",@_)->type("text/css")
  }

; sub src
  { my $obj=shift
  ; $obj->_thread->[0]="link"
  ; $obj->href(shift)->rel('stylesheet')
  ; splice(@{$obj->_thread},1,1);
  ; $obj
  }
  
; sub get
  { my $self=shift
  ; if( exists $self->_attributes->{'href'} )
     { return (bless $self, 'HO::Tag::Single')->get() }
    else
     { $self->insert("\n   -->\n")
     ; return (bless $self, 'HO::Tag::Double')->get()
     }
  }
  
; 1
