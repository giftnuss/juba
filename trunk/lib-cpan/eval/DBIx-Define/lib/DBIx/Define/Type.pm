  package DBIx::Define::Type
# **************************
; our $VERSION='0.01'
# *******************
; use strict; use warnings
; use base 'Class::Accessor::Fast'
  
; __PACKAGE__->mk_accessors
    ( 'data_type'       # string representation of the SQL data type
    , 'is_nullable'
    , 'default'
    )

; our %CONSTR =
    ( recordid => 'DBIx::Define::Type::RecordId'
    , integer  => 'DBIx::Define::Type::Integer'
    , number   => 'DBIx::Define::Type::Number'
    , text     => 'DBIx::Define::Type::Text'
    , word     => 'DBIx::Define::Type::Word'
    , date     => 'DBIx::Define::Type::Date'
    , time     => 'DBIx::Define::Type::Time'
    )

# diagnostics?
; sub get_type_object
    { my ($pack,$type,$args)=@_
    ; my $class = $CONSTR{$type} || $pack
    ; return $class->new($args)
    }

; sub set_type_class
    { my ($self,$type,$class) = @_
    ; $CONSTR{$type} = $class
    }

############################################
; sub sqltype 
    { my ($self) = shift
    ; $self->data_type
    } 

; sub sqlnullstr
    { my ($self) = shift
    ;   not defined $self->is_nullable ? ''
      : $self->is_nullable             ? 'NULL' : 'NOT NULL'
    }

; sub sqlsize
    { my ($self) = shift
    ; $self->size 
    }

; sub sqldefault
    { my ($self) = shift
    ; $self->default
    }

############################################

; package DBIx::Define::Type::Integer
; use base 'DBIx::Define::Type'
  
; __PACKAGE__->mk_accessors qw/size is_auto_increment/

; sub sqltype
    { 'INTEGER'
    }

; package DBIx::Define::Type::RecordId
; use base 'DBIx::Define::Type::Integer'

; 1
  
__END__
  

