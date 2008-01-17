  package Juba::Document
# **********************
; our $VERSION='0.01'
# *******************

################
# util classes
################
; use Package::Subroutine

################
# extensions
################
; use Juba::Document::DublinCore

################
# class
################
; use subs qw/init/
  
; use HO::common qw/node/

; use HO::class
    ( _lvalue => 'rdf'      => '$'
    , _lvalue => 'display'  => '$'
    , _lvalue => 'tmx'      => '$'
    )
    
################
; our %export
################
; sub import
    { my $self = shift
    ; export_to(scalar caller)
    ; strict->unimport
    ; $_ = $self->new(@_)
    }

; sub export_to
    { my $target = shift
    ; foreach my $ce (keys %export)
        { load_class Package::Subroutine::($export{$ce})
        ; Package::Subroutine::exporter( $target, $export{$ce}, $ce )
        }
    }
    
################
# methods
################
; sub init
    { my $self = shift
    ; ($self->$_)=node() for $self->sections
    ; $self
    }
    
; sub sections
    {qw/ rdf display tmx /}

# broadcast wird mit einem Objekt aufgerufen
; sub broadcast ($$)
    { my ($doc,$obj) = @_
    ; foreach my $sect ($doc->sections)
        { $doc->$sect->insert($obj) # should be pickup
	}
    }

; sub dispatch
    { my ($obj,$method,@args) = @_
    ; foreach my $sect ($obj->sections)
        { if(my $m = $obj->$sect->can($method))
	    { $_ = $obj
	    ; $m->(@args)
	    }
	}
    }

; 1
  

__END__
  
