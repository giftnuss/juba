  package DBIx::Define::Table
# ***************************
; our $VERSION='0.02'
; our $AUTHORITY='cpan:SKNPP'
# ***************************
; use DBIx::Define::Object

; use Coat
; extends 'DBIx::Define::Object'

; has 'order'       => (isa => 'Int')
; has 'name'        => (isa => 'Str')      # the table name
; has 'description' => (isa => 'Str')      # describe purpose of the table
; has 'columns'     => (isa => 'ArrayRef') # database columns
; has 'dbindice'    => (isa => 'ArrayRef') # column index
  
# is it now a singleton? why not.
; sub new
    { my ($pack,%args)=@_
    ; my $class = ref $pack || $pack
    
    ; my $self = DBIx::Define->get_table(class => $class, %args)
    ; unless($self)
        { do{ delete $args{$_} unless $class->can($_) } for keys %args
        ; $self = $class->SUPER::new(%args)
        ; $self->columns([])  unless $self->columns
        ; $self->dbindice([]) unless $self->dbindice
        }
    
    ; $self
    }

=head2 Methods

=over 4

=item add_column

Takes three arguments, the name of the column, the type object and
an optional hashref with additional arguments for the producer.

=cut

; sub add_column
    { my ($self,$column)=@_
    ; push @{$self->columns},$column
    ; $self
    }
  
; sub list_columns
    { my ($self)=@_
    ; if(wantarray)
	    { return @{$self->columns}
	    }
      else
        { return sub
            { my $idx if 0
            ; return $self->columns->[$idx++]
            }
        }
    }

; 1
  
__END__
  
