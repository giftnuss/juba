
; use strict
; use warnings

; use HO

; package HO::Tag
; use base 'HO'            

; sub new 
    { my ($class,$tag,@a)=@_;
    ; $class->SUPER::new($tag , @a )
    }
    
; sub _bopentag () { '<' }  # inline
; sub _closetag () { '>' }  # inline
; sub _bendtag  () { '</' } # inline

; package HO::Tag::Single
; use base 'HO::Tag'
    
; sub get
    { my  $self=shift
    ; my ($tag,@thread)=@{$self->_thread}
	
    ; my $r=$self->_bopentag.$tag.$self->get_attributes().$self->_closetag
    ; foreach ( @thread )
        { $r.= ref($_) ? $_->get() : $_ }
    ; $r
    }
    
; sub _closetag () { ' />' } # inline

; package HO::Tag::Double
; use base 'HO::Tag'

; sub get
    { my $self=shift
    ; my ($tag,@thread)=@{$self->_thread}
	
    ; my $r=$self->_bopentag.$tag.$self->get_attributes().$self->_closetag
	  
    ; foreach ( @thread )
        { next unless defined $_
        ; $r .= ref($_) ? $_->get() : $_
        }
    ; $r.=$self->_bendtag.$tag.$self->_closetag
    ; $r
    }
    
; package HO::Tag::Double::Suffix
; use base 'HO::Tag::Double'

; sub new
    { my $pack=shift
    ; my $htag=shift
    ; my $suffix
    ; if( ref($pack) )
        { my $tag=$pack->_thread->[0]
        ; my $pkg=ref($pack)
        ; $pkg=substr($pkg,-1*index(reverse($pkg),':'))
        ; $suffix=substr($tag,length($pkg))
        }
      else
        { $suffix=shift }
    ; $pack->SUPER::new("${htag}${suffix}",@_)
    }

; package HO::Tag::Double::Letter
; use base 'HO::Tag::Double'

; sub new
    { my $pack=shift
    ; my $htag=shift
    ; $pack->SUPER::new(substr($htag,0,1),@_)
    }
    
; 1

__END__
