  package Juba::Dot
# *****************
; our $VERSION='0.01'
# *******************
; use strict; use warnings

; use Package::Subroutine
#; use Package::Subroutine::Functions 'setglobal'
  
; sub import
    { my $pkg = shift
    ; export Package::Subroutine:: _ => grep { $pkg->can($_) } @_
    
    # install subroutines from package with a import function
    # no export is done by the container object
    # ; install Package::Subroutine $package, "import"
	 #  => sub { no strict 'refs'
	 #         ; export Package::Subroutine:: $package ,
	 #	                @{"${package}::EXPORT"}
	 #         }
    }

; sub coreelement
    { my $package = caller
    ; my ($subroutine,$subref) = @_
    ; $subref ||= sub { $package->new(@_) }
	  
    ; $Juba::Document::export{$subroutine} = $package
	 
    ; install Package::Subroutine $package => $subroutine
         => sub { my $obj = $subref->(@_)
                ; $_->broadcast($obj) # should be Juba::Document
	        }
    }

; sub has
    { my $package = caller
    ; my $subs = [@_]
	  
	
    }

; 1
  
__END__
  
=head1 NAME

Juba::Dot

=head1 SYNOPSIS

   package Kindof::Structure;
   use Juba::Dot 
       'coreelement', # 
       ;
   coreelement 'dc'
       
   