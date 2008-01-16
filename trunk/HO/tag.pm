  package HO::tag
# ***************
; use base 'HO::attr'
; our $VERSION = $HO::VERSION
# ***************************
  
; use HO::class
    _index => __is_single_tag => '$'

; sub _tag : lvalue
    { $_[0]->_thread->[0] }

; sub _begin_tag    () { '<'   } # inline
; sub _close_tag    () { '>'   } # inline
; sub _close_stag   () { ' />' } # inline
; sub _begin_endtag () { '</'  } # inline

; sub _is_single_tag : lvalue
    { if( defined $_[1] )
        { $_[0]->[&__is_single_tag] = $_[1] 
	; return $_[0] 
	}
      else
	{ return $_[0]->[&__is_single_tag]
	}
    }

; sub string
    { if( $_[0]->_is_single_tag )
        { return $_[0]->_single_tag }
      else
        { return $_[0]->_double_tag }
    }

; sub _single_tag
    { my ($tag,@thread)=$_[0]->content
	  
    ; my $r = $_[0]->_begin_tag . $_[0]->_tag . $_[0]->attributes_string . $_[0]->_close_stag
	  
    ;    $r .= ref($_) ? "$_" : $_ foreach @thread
    ; return $r
    }

; sub _double_tag
    { my ($tag,@thread)=$_[0]->content

    ; my $r = $_[0]->_begin_tag . $_[0]->_tag . $_[0]->attributes_string() . $_[0]->_close_tag

    ; $r .= ref($_) ? "$_" : $_ foreach @thread

    ; $r .= $_[0]->_begin_endtag . $_[0]->_tag . $_[0]->_close_tag
    ; return $r
    }

# overwritten methods
; sub replace
    { my ($self,@args)  = @_
    ; @{$_[0]->_thread} = ($_[0]->_tag,@args)
    }

; our %CATALOG

; sub class_builder
    { shift if @_ % 2 # called with package or object 
    ; my %args = @_

    ; $args{'base'}    ||= __PACKAGE__
    ; $args{'catalog'} ||= \%__PACKAGE__::CATALOG
    # $args{'accessor'} -> verschiedene Objekte �ber den selben Namen ansprechen

    ; sub
        { my ($classname => $baseclass => $tag => $access) = @_
        ; my $package = $args{'base'}.'::'.$classname
        ; return if defined $args{'catalog'}->{$package}

        ; $tag    ||= lc $classname
        ; $access ||= $args{'accessor'} || ucfirst $classname

        ; eval qq~ package $package; our \@ISA = qw($baseclass)
                 ; sub new { shift()->SUPER::new("$tag",\@_) }
                 ; sub $access { new $package (\@_) }
                 ~
        }
    }

; package HO::tag::suffix
; use base 'HO::tag'

; sub tag
    { $_[0]->_thread->[0].$_[0]->_thread->[1] }

; sub is_single_tag
    { defined $_[0]->_thread->[2] }

; sub content
    { my ($tag,$suffix,@t)=@{$_[0]->_thread}
    ; ($_[0]->tag,@t)
    }

; 1

__END__
