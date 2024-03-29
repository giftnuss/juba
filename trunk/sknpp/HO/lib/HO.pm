  package HO
# ==========
; use strict
; our $VERSION='0.61'
# ===================

# this way HO::class knows that there is a init method
; use subs qw/init/

; use HO::class

    _lvalue   => _thread => '@',

    _method   => insert   => sub
       { my $self = shift
       ; push @{$self->_thread}, map { ref eq 'ARRAY' ? new HO(@$_) : $_ } @_
       ; $self
       }

; sub init
    { return shift->insert( @_ ) }


; sub replace
    { my $self = shift
    ; @{$self->_thread}=()
    ; return $self->insert(@_)
    }


; sub splice
    { my $self = shift
    ; my $offset = shift
    ; my $length = shift
    ; return CORE::splice(@{$self->_thread},$offset,$length,@_)
    }


; sub string
    { my $self=shift
    ; return join("",$self->content)
    }

# better return a array ref in scalar context?
; sub content
    { return @{$_[0]->_thread} }

; sub concat
    { my ($o1,$o2,$reverse)=@_
    ; ($o2,$o1)=($o1,$o2) if $reverse
    ; return new HO::($o1,$o2)
    }

; sub copy
    { my ($obj,$arg,$reverse)=@_
    # I misunderstand overload docs, the arguments are already in the right order here.
    # note thate the * always creates an scalar context
    #; ($obj,$arg)=($arg,$obj) if $reverse
    ; my $num = defined($arg) && ($arg > 1) ? int($arg) : 1
    ; my @copy
    ; for ( 1..$num )
        { my $copy=$obj->new()
        ; $obj->duplicate($copy)
        ; push @copy,$copy
        }
    ; return wantarray ? @copy : defined($arg) ? \@copy : $copy[0] 
    }
    
# this helps to overwrite copy
; sub duplicate
    { my ($obj,$duplicate) = @_
    ; $duplicate ||= ref($obj)->new
    
    ; my @props = @{$obj}
    ; for my $prop (0..$#props)
        { if(ref $obj->[$prop] eq 'HASH')
            {
              $duplicate->[$prop] = {%{$obj->[$prop]}}
            }
          elsif(ref $obj->[$prop] eq 'ARRAY')
            {
              $duplicate->[$prop] = [@{$obj->[$prop]}]
            }
          else
            {
              $duplicate->[$prop] = $obj->[$prop]
            }
        }
    ; return $duplicate
    }

; sub count
   { return scalar @{$_[0]->_thread}
   }


; use overload
    '<<'     => "insert",
    '**'     => "insert",
    '""'     => "string",
    '+'      => "concat",
    '*'      => "copy",
    'bool'   => sub{ 1 },
    fallback => 1,
    nomethod => sub 
        { require Carp
        ; Carp::croak "illegal operator $_[3]." 
        }
  
; 1 ;

__END__

