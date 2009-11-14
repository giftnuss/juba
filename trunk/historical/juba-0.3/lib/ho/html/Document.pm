
; use strict

; use warnings
; no warnings 'void'

; package HO::HTML::Document

; use base 'HO::Document'
; our $VERSION='0.2.1'

; use HO::HTML        ( namespace => __PACKAGE__, functional => 1 )
; use HO::HTML::Meta  ( namespace => __PACKAGE__, functional => 1 )
; use HO::HTML::Style ( namespace => __PACKAGE__, functional => 1 )
; use HO::HTML::Script( namespace => __PACKAGE__, functional => 1 )
; use HO::HTML::Document::Type

; sub import
    { shift->slots qw(head title body meta style script) }
   
; sub new
    { my ($class)=shift
    ; my %p=@_;
    ; my $doctype  =$p{'doctype'} || 'transitional'
    ; my $titletext=$p{'title'} || ''
    ; my $metatags =$p{'metatags'} || []
    ; my $root=new HO::HTML::Document::Type
    ; my %slot=
        ( head   => Head()
        , title  => Title($titletext)
        , body   => Body()
        , meta   => new HO($metatags)
        , style  => Style()
        , script => Script()
        )
    ; my ($html)=(Html())
    ; $root << "\n" 
            << ($html << "\n" 
                      << ($slot{head} << $slot{title} 
                                      << $slot{meta} 
                                      << $slot{style} 
                                      << $slot{script}) 
                      << $slot{body}) << "\n"
 
    ; my $self=$class->SUPER::new()
    
    ; $self->set_root($root)
    ; while( my ($slot,$area)=each(%slot) )
        { $self->set_area($slot,$area) }
        
    ; $self
    }
    
; sub NoCache
    { my ($self)=shift
    ; $self->meta('<meta http-equiv="pragma" content="no-cache">',"\n"
                 ,'<meta http-equiv="expires" content="0">',"\n");
    ; $self
    }

; 1

__END__
