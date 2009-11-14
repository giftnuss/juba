
; use strict
; use warnings

; package HO::Structure

; use HO
; use Carp

; use base 'HO'
; our $VERSION='0.2.0'

; use constant AREAS => 0
; use constant ROOT  => 2

# Attribute werden noch nicht genutzt, aber es ist besser mit definiert um 
# Kompatibel mit der Basisklasse zu Bleiben 
; sub new
  { my ($class) = @_
  ; bless [ {} , {}  # AREAS , ATTR
          ], $class
  }
  
; sub _areas { $_[0]->[AREAS] }

; sub _root { $_[0]->[ROOT] }

; sub _thread { $_[0]->_root->_thread }

; sub slots
  { my ($class,@nodes)=@_
  ; $class = ref $class if ref $class
  ; eval qq~package $class; sub $_ { shift()->fill( "$_", \@_ ) }~ for @nodes
  }

; sub fill
  { my ($obj,$key,@values) = @_
  ; my $area=$obj->_areas->{$key}
  ; if( defined $area )
     { $area->insert( @values ) }
	  else
     { carp "Area $key is not defined!"
     ; return undef
     }
  ; return $area
  }

; sub set_area
  {	my ($obj,$key,$node) = @_;
	; unless( $node->can("insert") && $node->can("get") )
     { carp "The area named with $key is not a valid object."
     ; return undef
     }
	; $obj->_areas->{$key} = $node;
  ; $obj
  }

; sub set_alias($$$)
  { my ($obj,$oldkey,$newkey) = @_
  ; my $area = $obj->_areas->{$oldkey}
  ; unless( defined $area )
    { carp "Can not set alias. Unknown area $oldkey!"
    ; return undef
    }
  ; $obj->_areas->{$newkey}=$area
  ; $obj
  }

; sub set_root
  {	my ($obj,$node)=@_
  ; croak "Not a valid root object." unless $node->can("get")
  ;	$obj->[ROOT]=$node	
  }

; sub get
  {	my ($obj) = @_;
  ; my $root=$obj->_root
  ; croak "No root for structure." unless $root
  ; return $root->get();
  }

; sub get_area
  {	my ($obj,$key) = @_
  ; my $area=$obj->_areas->{$key}
  ;	croak "$key is not defined." unless $area
  ; $area	
  }

; sub get_root
  {	my ($obj) = @_
  ; my $root=$obj->_root
  ; unless( $root )
    { carp "Root object is not defined."
    ; return undef
    }
  ; return $root
  }

; sub set_areas
  { my ($obj,@arg) = @_
  ; my %h;
  ; if( ref $arg[0] eq "HASH" )
     { %h=(%h,%{$_}) foreach @arg }
	  else
     { %h=@arg }
  ; $obj->set_area($_,$h{$_}) foreach keys %h;
  }

; 1

__END__
