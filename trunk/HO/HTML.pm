  package HO::HTML
# ****************
; our $VERSION='0.01'
# *******************

; use strict; use warnings; use utf8

; require Exporter  
; our @ISA = ('Exporter')
; our (@EXPORT_OK,@EXPORT)

; use HO::HTML::element

# L = loaded
# Function = Name der Standardfunktion im HO::HTML Namensraum
# A = Basisklasse (index)
# T = is_single_tag
# H = nur im Header
# B = Block Element
# I = Inline Element
# S = in strict erlaubt
# D = nur daten erlaubt
       
; our @elements = #   L, Function,     A, T, S, B  
    ( 'a'        => [ 0, 'A',          0, 0, 1, 0, ]
    , 'abbr'     => [ 0, 'Abbr',       0, 0, 1, 0, ]
    , 'acronym'  => [ 0, 'Acronym',    0, 0, 1, 0, ]
    , 'address'  => [ 0, 'Address',    0, 0, 1, 1, ]
    , 'applet'   => [ 0, 'Applet',     0, 0, 0, 0, ]
    , 'area'     => [ 0, 'Area',       0, 1, 1, 0, ]
    , 'b'        => [ 0, 'Bold',       0, 0, 1, 0, ]
    , 'base'     => [ 0, 'Base',       0, 1, 1, 0, ]
    , 'basefont' => [ 0, 'Basefont',   0, 1, 0, 0, ]
    , 'bdo'      => [ 0, 'Bdo',        0, 0, 1, 0, ]
    , 'big'      => [ 0, 'Big',        0, 0, 1, 0, ]
    , 'blockquote', [ 0, 'Blockquote', 0, 0, 1, 1, ]
    , 'body'     => [ 0, 'Body',       0, 0, 1, 0, ]
    , 'br'       => [ 0, 'Br',         0, 1, 1, 0, ]
    , 'button'   => [ 0, 'Button',     0, 1, 1, 0, ]
    , 'caption'  => [ 0, 'Caption',    0, 0, 1, 0, ]
    , 'center'   => [ 0, 'Center',     0, 0, 0, 1, ]
    , 'cite'     => [ 0, 'Cite',       0, 0, 1, 0, ]
    , 'code'     => [ 0, 'Code',       0, 0, 1, 0, ]
    , 'col'      => [ 0, 'Col',        0, 0, 1, 0, ]
    , 'colgroup' => [ 0, 'Colgroup',   0, 0, 1, 0, ]
    , 'dd'       => [ 0, 'Dd',         0, 0, 1, 0, ]
    , 'del'      => [ 0, 'Del',        0, 0, 1, 1, ]
    , 'dfn'      => [ 0, 'Dfn',        0, 0, 1, 0, ]
    , 'dir'      => [ 0, 'Dir',        0, 0, 0, 1, ]
    , 'div'      => [ 0, 'Div',        0, 0, 1, 1, ]
    , 'dl'       => [ 0, 'Dl',         0, 1, 1, ]
    , 'dt'       => [ 0, 'Dt',         0, 1, 0, ]
    , 'em'       => [ 0, 'Em',         0, 1, 0, ]
    , 'fieldset' => [ 0, 'Fieldset',   0, 1, 1, ]
    , 'font'     => [ 0, 'Font',       0, 0, 0, ]
    , 'form'     => [ 0, 'Form',       0, 1, 1, ]
    , 'frame'    => [ 0, 'Frame',      0, 0, 0, ]
    , 'frameset' => [ 0, 'Frameset',   0, 0, 0, ]
    , 'h1'       => [ 0, 'H1',         1, 0, 1, 1, ]
    , 'h2'       => [ 0, 'H2',         1, 0, 1, 1, ]
    , 'h3'       => [ 0, 'H3',         1, 0, 1, 1, ]
    , 'h4'       => [ 0, 'H4',         1, 0, 1, 1, ] 
    , 'h5'       => [ 0, 'H5',         1, 0, 1, 1, ] 
    , 'h6'       => [ 0, 'H6',         1, 0, 1, 1, ]
    , 'head'     => [ 0, 'Head',       0, 0, 1, 0, ] 
    , 'hr'       => [ 0, 'Hr',         0, 1, 1, 1, ]
    , 'html'     => [ 0, 'Html',       0, 0, 1, 0, ]
    , 'i'        => [ 0, 'Italic',     0, 0, 1, 0, ]
    , 'iframe'   => [ 0, 'IFrame',     0, 0, 0, 0, ]
    , 'img'      => [ 0, 'Img',        0, 1, 1, 0, ]
    , 'input'    => [ 0, 'Input',      0, 1, 1, 0, ]
    , 'ins'      => [ 0, 'Ins',        0, 0, 1, 1, ]
    , 'isindex'  => [ 0, 'IsIndex',    0, 0, 0, 1, ]
    , 'kbd'      => [ 0, 'Kbd',        0, 0, 1, 0, ]
    , 'label'    => [ 0, 'Label',      0, 0, 1, 0, ]
    , 'legend'   => [ 0, 'Legend',     0, 0, 1, 0, ]
    , 'li'       => [ 0, 'Li',         0, 0, 1, 0, ]
    , 'link'     => [ 0, 'Link',       0, 1, 1, 0, ]
    , 'map'      => [ 0, 'Map',        0, 0, 1, 0, ]
    , 'menu'     => [ 0, 'Menu',       0, 0, 0, 1, ]
    , 'meta'     => [ 0, 'Meta',       0, 1, 1, 0, ]
    , 'noframes' => [ 0, 'NoFrames',   0, 0, 0, 1, ]
    , 'noscript' => [ 0, 'NoScript',   0, 0, 1, 1, ]
    , 'object'   => [ 0, 'Object',     0, 0, 1, 0, ]
    , 'ol'       => [ 0, 'Ol',         0, 0, 1, 1, ]
    , 'optgroup' => [ 0, 'Optgroup',   0, 0, 1, 0, ]
    , 'option'   => [ 0, 'Option',     0, 0, 1, 0, ]
    , 'p'        => [ 0, 'P',          0, 0, 1, 1, ]
    , 'param'    => [ 0, 'Param',      0, 1, 1, 0, ]
    , 'pre'      => [ 0, 'Pre',        0, 0, 1, 1, ]
    , 'q'        => [ 0, 'Q',          0, 0, 1, 0, ]
    , 's'        => [ 0, 'S',          0, 0, 0, 0, ]
    , 'samp'     => [ 0, 'Sample',     0, 0, 1, 0, ]
    , 'script'   => [ 0, 'Script',     0, 0, 1, 0, ]
    , 'select'   => [ 0, 'Select',     0, 0, 1, 0, ]
    , 'small'    => [ 0, 'Small',      0, 0, 1, 0, ]
    , 'span'     => [ 0, 'Span',       0, 0, 1, 0, ]
    , 'strike'   => [ 0, 'Strike',     0, 0, 0, 0, ]
    , 'strong'   => [ 0, 'Strong',     0, 0, 1, 0, ]
    , 'style'    => [ 0, 'Style',      0, 0, 1, 0, ]
    , 'sub'      => [ 0, 'Sub',        0, 0, 1, 0, ]
    , 'sup'      => [ 0, 'Sup',        0, 0, 1, 0, ]
    , 'table'    => [ 0, 'Table',      0, 0, 1, 1, ]
    , 'tbody'    => [ 0, 'TBody',      0, 0, 1, 0, ]
    , 'td'       => [ 0, 'Td',         0, 0, 1, 0, ]
    , 'textarea' => [ 0, 'Textarea',   0, 0, 1, 0, ]
    , 'tfoot'    => [ 0, 'TFoot',      0, 0, 1, 0, ]
    , 'th'       => [ 0, 'Th',         0, 0, 1, 0, ]
    , 'thead'    => [ 0, 'THead',      0, 0, 1, 0, ]
    , 'title'    => [ 0, 'Title',      0, 0, 1, 0, ]
    , 'tr'       => [ 0, 'Tr',         0, 0, 1, 0, ]
    , 'tt'       => [ 0, 'Tt',         0, 0, 1, 0, ]
    , 'u'        => [ 0, 'U',          0, 0, 0, 0, ]
    , 'ul'       => [ 0, 'Ul',         0, 0, 1, 1, ]
    , 'var'      => [ 0, 'Var',        0, 0, 1, 0, ]
    )
    
; our @baseclasses =
    ( 'HO::HTML::element'
    , 'HO::HTML::element::header'
    , 'HO::HTML::Input'
    )

; sub seq_props
    { map { ($_*=2)-1 } 1..($#elements+1)/2
    }
    
; sub list_names
    { map { $elements[$_*2] } 0..($#elements-1)/2
    }
    
############################
# IMPORT
# tags => arrayref with tags to build
# functional => true or arrayref - export tags as functions
############################

; sub import
  { my ($pkg,@args)=@_
  ; our @elements
  ; local $_
	
  ; for (0,2)
      { if(defined($args[$_]) && $args[$_] eq 'tags')
          { my (undef,$tags) = splice(@args,$_,2)
	       ; $pkg->create_tags(@{$tags})
	       }
      }

  ; unless(grep { $elements[$_]->[0] } seq_props())
      { $pkg->create_tags($pkg->list_names)
      }
      
  ; { local @EXPORT
    ; if(@args && $args[0] eq 'functional')
      { #local @EXPORT
      ; if(ref $args[1] eq 'ARRAY')
          { @EXPORT = @{$args[1]}
          }
        else
          { for(my $i=1; $i<=$#elements; $i+=2)
              { push @EXPORT, $elements[$i]->[1]
                  if $elements[$i]->[0]
              }
          }
      ; __PACKAGE__->export_to_level(1,$pkg,@EXPORT)
      }
    }
  }
  
; sub create_tags
    { my ($pkg,@tags) = @_
    ; our @elements
    ; TAGS:
      foreach my $tag (@tags)
        { for(my $i=0; $i<$#elements; $i+=2)
            { if($tag eq $elements[$i])
                { unless($elements[$i+1]->[0])
                    { $pkg->create_a_tag($i)
                    ; $elements[$i+1]->[0] = 1
                    }
                ; next TAGS
                }
            }
        }
    }

; my $default_init
    
; sub create_a_tag
    { my ($pkg,$idx) = @_
    ; our (@elements,@baseclasses,@inits)
    ; my $p = $idx+1
    
    ; my $codegain = $inits[$elements[$p]->[2]]

    ; HO::class::make_subclass
	    ( of => [ $baseclasses[ $elements[$p]->[2] ] ]
	    , shortcut_in  => 'HO::HTML'
	    , name         => $elements[$idx]
	    , shortcut     => $elements[$p]->[1]
	    , codegen      => $codegain
	        ->( $elements[$p]->[3], # is_singletag
		       , $elements[$idx]
		       )
       )
    }

; $default_init = sub
    { my ($single,$name) = @_
    ; return sub
        { return sprintf(<<'__PERL__',$single,$name)
	      
; sub init 
      { my ($self,@args)=@_
      ; $self->_is_single_tag = %d
      ; $self->insert("%s",@args)
      }

__PERL__

        }
    }
    
; my $header_init = sub
    { my ($single,$name)=@_
    ; return sub
        { return sprintf(<<'__PERL__',$single,$name)
        
; sub init
      { my ($self,@args)=@_
      ; $self->_is_single_tag = %d
      ; $self->insert("%s",@args)
            
      ; my $level = $self->default_level           
      ; $self->level($level)
      }

__PERL__

        }
    }

; our @inits = ($default_init,$header_init)

#############################
# Special Functions
#############################
# needs many fixes for more header elements
; sub H
    { my ($level,@args) = @_
    ; (($level ||= 1) && $level>0 && $level<7) or 
        do { unshift @args, $level; $level=1 }
    ; if(my $header = HO::HTML->can('H'.$level))
        { return &$header(@args)
        }
    ; Carp::croak "Header element class 'h$level' not initialized."
    }

; 1

__END__

    
; sub _make_tags
  { my $baseclass = caller(0)
  ; my %args = @_
  ; my @tags = @{$args{'tags'}}
  ; push @TAGS,@tags
	
  ; foreach my $tag (@tags)
      { HO::class::make_subclass
	    ( of => [ $baseclass ]
	    , shortcut_in  => 'HO::HTML'
	    , name         => $tag
	    , codegen      => $args{'codegen'}
      )}
  }
  
; package HO::HTML::Double
; use base qw/HO::tag HO::attr::autoload HO::insertpoint/
  
; our @TAGS = qw
  ( Html Head Title Body
    A Big Div P Pre Small Span Sub Sup
    Caption Colgroup Col Table Thead Tbody Tfoot Tr Th Td
    Ol Ul Li Dl Dd Dt
    Blockquote Q
    Button Fieldset Form Label Legend Option Select Textarea 
  )
  
; sub create_tags
  { HO::HTML::_make_tags
    ( tags    => $_[1]
    , codegen => sub 
        { my %args = @_; return sprintf <<'__PERL__'
	      
  sub init 
      { my ($self,@args)=@_
      ; $self->_is_single_tag(0)
      ; $self->insert("%s",@args)
      }

__PERL__
	, lc($args{'name'})
	}
    )
  }

; __PACKAGE__->create_tags(\@TAGS)
  
; package HO::HTML::Single
; use base qw/HO::tag HO::attr::autoload HO::insertpoint/
  
; our @TAGS = qw(Br Hr Img Input)

; sub _close_stag   () { ' >' } # inline

; HO::HTML::_make_tags(tags => \@TAGS
    , codegen =>
        sub { my %args = @_
	    ; 'sub init {my ($self,@args)=@_'
	     .';$self->_is_single_tag(1)'
	     .';$self->insert("'.lc($args{'name'}).'",@args)}'
	    }
    )

; 1


; use strict

; use warnings

; package HO::HTML::Input

; use HO::HTML
; use HO::Exporter
; our @ISA=('HO::Tag::Single','HO::Exporter');

; our $VERSION = '0.0.1'
; our @EXPORT
; our %defined

; sub new
    { my ($class,@arg)=@_
    ; $class = ref $class if ref $class
    ; my $self = bless new Input(@_) , $class
    ; $self->type(lc $class)
    }

; sub get_attributes
    { my ($self)=@_
    ; my ($r,$v)=("","")
    ; my %attr = %{$self->_attributes}
    ; foreach ( keys %attr )
        { $v=$attr{$_}
        ; $r .= ref $v        ? sprintf(" %s=\"%s\"",$_,$v->get) :
                ! defined $v  ? sprintf(" %s",$_)                 
                              : sprintf(" %s=\"%s\"",$_,$v)
        }
    ; return $r
    }
    
; sub import
    { my $class=shift
    ; my %p=( namespace => '', functional => 0, @_)
    ; my $ns=$p{namespace}; $ns.='::' if $ns 
    ; 
    ; my @packages = qw(Radio Text Checkbox Hidden IButton)
    ; foreach ( @packages )
        { my $pack="${ns}$_"
        ; unless( $defined{$pack} )
            { my $type=lc
            ; $type=substr($type,1) if $type eq 'ibutton'
            ; eval qq~ package $pack; our \@ISA=qw(${ns}Input)
                     ; sub new { shift()->SUPER::new()->type("$type") }
                     ~
            ; $defined{$pack}++        
            }
        ; $class->register(\@EXPORT, $_, $pack ) if $p{functional}
        }
    }
    
; 1

__END__

=head1 NAME

HO::HTML::Input

=head1 SYNOPSIS


; use strict
; use warnings

; package HO::HTML::Style

; use HO::Tag
; use HO::Exporter
; use base ('HO::Tag','HO::Exporter')

; our $VERSION='0.021'
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
  ; $class->SUPER::new(shift(),"\n",@_)->type("text/css")
  }
  
; sub Style
  { __PACKAGE__->new('style',@_)
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
     { return (bless $self, 'HO::Tag::Double')->get() }
    else
     { return (bless $self, 'HO::Tag::Double')->get() }
  }
  
; 1


; use strict
; use warnings

; package HO::HTML::Script

; use HO::Tag
; use HO::Exporter
; use base ('HO::Tag','HO::Exporter');

; use Data::Dumper

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
   ; my $r
   ; if( exists $self->_attributes->{'src'} )
      { $r=(bless $self, 'HO::Tag::Double')->get() }
     elsif( exists $self->_attributes->{'nocomment'} )
      { splice( @{$self->_thread},1,1 )
      ; delete $self->_attributes->{'nocomment'}
      ; $r=(bless $self, 'HO::Tag::Double')->get()
      }
     else
      {	$self->insert("\n//-->")
      ; $r=(bless $self, 'HO::Tag::Double')->get()
      }
   ; $r
   }
   
; sub nocomment
   { my $self=shift
   ; $self->bool_attribute("nocomment")
   ; $self
   }

; 1

__END__
   

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
 # a TODO
 #   ; for ( 'Refresh' )
 #       { eval qq~ package ${ns}$_; our \@ISA=qw(HO::
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
