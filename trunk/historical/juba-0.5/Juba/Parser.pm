
;  use strict

; package Juba::Parser

; use HTML::Parser
; use File::Basename

; sub new
    { my ($class,$text)=@_
    ; bless 
        { input     => extract_input($text)
        , stylefile => extract_stylefile($text)
        , title     => extract_title($text)
        },$class
    # ; $self->{input} = $text =~ /<body>(.*)<\/body>/s && $1
    # ; $self->{stylefile} = $text =~ /<link\ rel\=\"stylesheet\"\ href\=\"\/html\/css\/(.*?)\.css/ && $1
    }
    
; sub AUTOLOAD
    {	my $self=shift
	  ; our $AUTOLOAD =~ s/.*:://
    ; $self->{$AUTOLOAD}
    }
    
; sub extract_input
    { my $text=shift
    ; my $input
    ; my $p = HTML::Parser->new(api_version => 3)
    ; my $starthandler = sub
        { return if shift ne 'body'
        ; my $self=shift
        ; $self->handler( start   => sub{ $input.=shift }, "text" )
        ; $self->handler( default => sub{ $input.=shift }, "text" )
        ; $self->handler( end     => sub
            { my ($tag,$pa,$t)=@_
              ; if( $tag eq 'body' ) { $pa->eof }
                else { $input.=$t } 
            } , "tagname,self,text" )
        }
    ; $p->handler( start => $starthandler, "tagname,self")
    ; $p->parse($text)
    ; $input
    } 
    
; sub extract_stylefile
    { my $text=shift
    ; my $stylefile
    ; my $p = HTML::Parser->new(api_version => 3)
    ; my $starthandler = sub
        { my ($tag,$pa,$attr)=@_
        ; $pa->eof if $tag eq 'body'
        ; return if shift ne 'link'
        ; return if $attr->{rel} ne "stylesheet"
        ; $stylefile=basename($attr->{href},'.css')
        }
    ; $p->handler( start => $starthandler, "tagname,self,attr" )
    ; $p->parse($text)
    ; $stylefile
    }
      
; sub extract_title
    { my $text=shift
    ; my $title
    ; my $p = HTML::Parser->new(api_version => 3)
    ; my $starthandler = sub
        { return if shift ne "title"
        ; my $self = shift
        ; $self->handler(text => sub { $title=shift }, "dtext")
        ; $self->handler(end  => sub { shift->eof if shift eq "title"; },
                                     "tagname,self");
        }
    ; $p->handler( start => $starthandler, "tagname,self")
    ; $p->parse($text)
    ; $title
    }
    
; "giftnuss"
