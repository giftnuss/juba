  package DBIx::Define
# ********************
; our $VERSION='0.01'
# *******************
; use strict; use warnings; use utf8

; use DBIx::Define::Autoload
; use DBIx::Define::Column
; use DBIx::Define::Table
; use DBIx::Define::Type

############################################################
; use Package::Subroutine
############################################################

; my $currentschema   # default schema for Operations
; my %tblstore 

# a subclass should import it or rewrite it.
; sub import
    { my ($pack,%args) = @_
    ; my $caller = caller

    ; $pack->new_table(caller => $caller, %args)
	  
    # - provide_column - a class which have an alternative column function
    # - provide_tblindex - dito for a table index class
    ; export Package::Subroutine::
        (( $args{'provide_column'} || 'DBIx::Define' ) 
            => qw/column/ 
        )
    ; export Package::Subroutine:: 
        (( $args{'provide_index'} || 'DBIx::Define::Index') 
            => qw/tblindex/ 
        )
    ; export Package::Subroutine::
        (( $args{'provide_autoload'} || 'DBIx::Define::Autoload') 
            => qw/AUTOLOAD/ 
        )
              
    ; set_base_class Package::Subroutine::
        ( $caller => ($args{'provide_base'} || 'DBIx::Define::Table') )
    }    

# This subroutine returns no object. Instead the table object
# The work to initialize a new schema 

# is done by a constructor only to make subclassing easier.
# All methods from this class class are static or private.
#
# The constructor creates a new table object and stores them in the storage
# under the packages name. then export happens.
# Finally it sets the default schema to the currently used.
# - schema -- set schema name / overwrite get_default_schema_name
# - caller -- caller could be anything in this constructor, if you want.
# - instance_of -- the parameter which could represent a table class

; sub new_table
    { my ($pack,%args)=@_
    ; my $class  = ref $pack || $pack
    ; my $caller = $args{'caller'} || caller

    ; my ($schema) = $args{'schema'}
                   ? delete $args{'schema'}
	               : $class->get_default_schema_name($caller)

    ; unless( $args{'name'} )
        { $args{'name'} = _pkg2table($caller)
	}
	
    ; my ($create) = delete($args{'instance_of'}) || 'DBIx::Define::Table'
    
    ; $class->_set_current_schema($schema)
    
    ; unless(exists $tblstore{$schema}->{$caller})
	    { my $order = 1 + keys %{$tblstore{$schema}->{$caller}}
	    ; $tblstore{$schema}->{$caller} = $create->new(order => $order, %args) 
	    }

    }

# the method to get the table object
# shares a lot of code with the method above
; sub use_table
    { my ($self,%args) = @_
    ; my ($caller) = $args{'caller'} || caller
    ; my ($schema) = $args{'schema'} || $self->_get_current_schema
    ; $tblstore{$schema}->{$caller}
    }

# a method which creates a schema name. The default is
# to create name from caller package. This is the only
# argument given from standard constructor.
; sub get_default_schema_name
    { my ($self,$caller)=@_
    ; _pkg2schema($caller)
    }

# Retrieves a sorted list of all used schema names
; sub list_schema_names
    { sort keys %tblstore
    }

; sub _set_current_schema
    { $currentschema = $_[1]
    }

; sub _get_current_schema
    { $currentschema
    }

# Retrieves a table object by name
; sub get_table
    { my ($self,%args)=@_
    ; my $schema = $args{'schema'} || $currentschema
    
    # get table by class name
    ; if( $args{'class'} )
        { return $tblstore{$schema}->{$args{'class'}}
        }
    
    ; return undef unless defined (my $table=$args{'name'})
    
    ; foreach my $o (values %{$tblstore{$schema}})
        { return $o if $o->name eq $table 
	    }
    ; warn "No table $table found"
    ; return undef
    }
    
# this function is usually exported by DBIx::Define
# a column object is created and stored in the schema
# para: schema -- specify schema
# para: caller -- specify table
; sub column
    { my ($name,$type,%args) = @_
    ; my $class  = delete($args{'instance_of'}) || 'DBIx::Define::Column'
    ; my $column = $class->new(name => $name,type => $type, %args)
	  
    ; my $caller = $args{'caller'} || caller
    ; my $table  = DBIx::Define->use_table('caller' => $caller)
	  
    ; $table->add_column($column)
    }

#############################################################
# simple private utility functions
#############################################################
# das wird sicher auch gebraucht
; sub _pkg2schema
    { my @sl = split /::|'/, $_[0]
    ; @sl > 1 ? join('-',@sl[0...$#sl-1]) : $sl[0]
    }

# das ist nur damit eine etwas sinnvolle Vorbelegung existiert.
; sub _pkg2table
    { my @sl = split /::|'/, $_[0]
    ; pop @sl
    }

; 1
  
__END__
  
