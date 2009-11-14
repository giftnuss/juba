; package HO

; use strict
; use Carp

=head1 NAME

HO - Hierarchical Objects

=head1 VERSION

Version 0.5.4

  $Header: $
  
=cut

; our $VERSION='0.5.5'
; require 5.005

=head1 SYNOPSIS

C<HO> stands for Hirarchical Objects and plays the role as base class 
and interface for different extended objects. With this object it 
is simple to build up a hirarchy by the way to put one object into 
another and finally create a string from the whole structure.

 use HO;
 no warnings 'void';

 my $obj=new HO('text',$other_object);
 
 $obj->insert('more text');
 $obj << $another_object ** 'anymore text';
 
 print $obj->get;

=head2 WARNING

If an object is inserted somewhere inside of hisself an endless
loop will be the result of the get method. In the future another class
maybe C<HO::Safe> will targeting this issue.

=cut

; use constant THREAD      => 0
; use constant ATTRIBUTES  => 1
; use constant INSERTPOINT => 2

; our $DEBUG=0

; sub new
    { my $this = shift
    ; my $class = ref($this) || $this
    ; my $self  = [ [] , {} ]
    ; bless $self, $class
    ; $self->insert( @_ )
    }
    
; sub _thread
    { $_[0]->[THREAD] }
    
; sub _set_insertpoint
    { $_[0]->[INSERTPOINT]=$_[1] 
    ; return $_[0]
    }
    
; sub _insertpoint
    { $_[0]->[INSERTPOINT] }

; sub _attributes
    { $_[0]->[ATTRIBUTES] }
    
=head2 insert

 Usage     : How to use this function/method
 Purpose   : What it does
 Returns   : What it returns
 Argument  : What it wants to know
 Throws    : Exceptions and other anomolies
 Comments  : This is a sample subroutine header.
           : It is polite to include more pod and fewer comments.

See Also   : 

=cut

; sub insert
    { my $self = shift;
    ; my @arg = @_;
  
    ; if( ref $arg[0] eq "ARRAY" )
        { @arg = @{$arg[0]} }
	
    ; if( $self->_insertpoint )
        { $self->_insertpoint->insert(@arg) }
      else
        { push( @{$self->_thread}, @arg) }
        
    ; return $self
    } 

=head2 get

 Usage     : How to use this function/method
 Purpose   : What it does
 Returns   : What it returns
 Argument  : What it wants to know
 Throws    : Exceptions and other anomolies
 Comments  : This is a sample subroutine header.
           : It is polite to include more pod and fewer comments.

See Also   : 

=cut

; sub get
    { my $self=shift
    ; my $r   = ""
    ; foreach ( @{$self->_thread} )
        { 
          $r .= ref($_) ? $_->get() : $_
        }
    ; return $r;
    }

=head2 concat

 Usage     : How to use this function/method
 Purpose   : What it does
 Returns   : What it returns
 Argument  : What it wants to know
 Throws    : Exceptions and other anomolies
 Comments  : This is a sample subroutine header.
           : It is polite to include more pod and fewer comments.

See Also   : 

=cut

; sub concat
    { my ($o1,$o2,$reverse)=@_
    ; ($o2,$o1)=($o1,$o2) if $reverse
    ; return new HO($o1,$o2)
    }

=head2 copy

 Usage     : How to use this function/method
 Purpose   : What it does
 Returns   : What it returns
 Argument  : What it wants to know
 Throws    : Exceptions and other anomolies
 Comments  : This is a sample subroutine header.
           : It is polite to include more pod and fewer comments.

See Also   : 

=cut

; sub copy
    { my ($obj,$arg)=@_
    ; my $num = defined $arg ? $arg : 1
    ; my @copy
    ; for ( 1..$num )
        { my $copy=$obj->new()
        ; @{$copy->_thread}    =@{$obj->_thread}
        ; %{$copy->_attributes}=%{$obj->_attributes}
        ; $copy->_set_insertpoint($obj->_insertpoint)
        ; push @copy,$copy
        }
    ; wantarray ? @copy : defined $arg ? $copy[0] : \@copy
    }

; sub multiply
    { my ($o,$num)=@_
    ; return new HO($o->copy($num))
    }
    
; sub insertpoint
    { my ($self,$inp)=@_
    ; if( defined $inp )
        { return $self->_set_insertpoint($inp) }
      else
        { my $obj=$self->_insert_point
        ; return $obj ? $obj : $self
        }
    }
    
; sub get_attributes
    { my ($self)=@_
    ; my ($r,$v)=("","")
    ; my %attr = %{$self->_attributes}
    ; foreach ( keys %attr )
        { $v=$attr{$_}
        ; $r .= ref $v        ? sprintf(" %s",$v->get) :
                ! defined $v  ? sprintf(" %s",$_)                 
                              : sprintf(" %s=\"%s\"",$_,$v)
        }
    ; return $r
    }

; sub AUTOLOAD
    { my $self=shift
    ; our $AUTOLOAD
    ; croak $AUTOLOAD if $HO::DEBUG 
    ; $AUTOLOAD =~ s/.*:://
    ; $self->_attributes->{ $AUTOLOAD }=shift;
    ; return $self;
    }

; sub set_attribute
    { my ($self,$key,$value)=@_
    ; $self->_attributes->{$key} = $value
    ; $self
    }
  
; sub get_attribute
    { my ($self,$key)=@_
    ; $self->_attributes->{$key}
  }
  
=head1 operator <<

	$obj << $other_obj; # or
	$obj << \@array;    # because a plain Array doesn't work with operator

This makes the code more like c++. Funny Thing, which works fine. Only the warning
is produced because the void context. This is disabled with:
  
  no warnings 'void'

=cut  


; use overload
    '<<'     => "insert",
    '**'     => "insert",
    '""'     => "get",
    '+'      => "concat",
    '*'      => "multiply",
    'bool'   => sub{ 1 },
    fallback => 1,
    nomethod => sub { croak "illegal operator $_[3] in ".join(" ",caller(2) ) }

  
; 1

__END__


  


=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.


=head1 USAGE



=head1 BUGS



=head1 SUPPORT



=head1 AUTHOR

	Sebastian Knapp
	CPAN ID: SKNPP
	Computer-Leipzig.com
	sk@computer-leipzig.com
	
=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut




############################################# main pod documentation end ##


################################################ subroutine header begin ##

=head2 sample_function

 Usage     : How to use this function/method
 Purpose   : What it does
 Returns   : What it returns
 Argument  : What it wants to know
 Throws    : Exceptions and other anomolies
 Comments  : This is a sample subroutine header.
           : It is polite to include more pod and fewer comments.

See Also   : 

=cut

################################################## subroutine header end ##
