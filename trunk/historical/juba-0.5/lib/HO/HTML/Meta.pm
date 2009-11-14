
; use strict

; use warnings

; package HO::HTML::Meta

; use HO::HTML
; use base 'HO::Tag::Single'

; sub import
    { my ($class,$ns)=@_
    ; $class = ref $class if ref $class
    ; $ns.= $ns ? '::' : ''
    
    ; my @metaname=qw(Author Copyright Description Generator 
                      Keywords Publisher);
    #; my @metaequiv=qw(Charset);
    
    ; foreach ( @metaname )
        { eval "package ${ns}$_; our \@ISA=qw(HO::HTML::Meta::name)" }
    ; for ( 'Charset' )
        { eval qq~ package ${ns}$_; our \@ISA=qw(HO::HTML::Meta::equiv)
                 ; sub meta { my \$o=\$_[0]->SUPER::meta('content-type')
                            ; \$o->content("text/html; charset=\$_[1]") }
                 ~                    
        }
    }

; package HO::HTML::Meta::name
; use base 'HO::HTML::Meta'

; sub meta
    { my ($class,$type,$value)=@_
    ; $class = ref $class if ref $class
    ; my $self = bless new Meta() , $class
    ; $self->name(lc $class)->content($value)
    }
    
; package HO::HTML::Meta::equiv
; use base 'HO::HTML::Meta'
    
; sub meta
    { my ($class,$equiv)=@_
    ; $class = ref $class if ref $class
    ; my $self = bless new Meta() , $class
    ; $self->set_attribute("http-equiv",$equiv)
    }
    
; 1

__END__
    
   #  <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
