  package Juba::Dot
# *****************
; our $VERSION='0.01'
# *******************
; use strict; use warnings

; use Package::Subroutine
; use Package::Subroutine::Functions qw/setglobal getglobal/
  
; sub import
    { my $pkg = shift
    # this could be called: export_what_I_can
    ; export Package::Subroutine:: _ => grep { $pkg->can($_) } @_
    }

# it is a possible base class for secondary elements    
; use HO::class
    
# this stores the package name or so for Class
; my $class
; sub Class 
    { my ($self)
    ; $self  = shift if @_>=2
    ; $class = shift || caller 
    ; return $self
    }

# only one class per call
; sub extends
    { my ($self)
    ; $self = shift if @_>=2
    ; my $me       = $class || caller
    ; my $extends  = shift
    ; setglobal($me,'@ISA',$extends)
    ; return $self
    }

; sub coreelement
    { my $package = caller
    ; my ($subroutine,$subref) = @_
    
    # isa checken
    # this implies a restrictition that a pure base package
    # can't have a coreelement
    ; setglobal($package,'@ISA','Juba') unless getglobal($package,'@ISA')
    
    ; $subref ||= sub { $package->new(@_) }
	  
    ; $Juba::Document::export{$subroutine} = $package
	 
    ; install Package::Subroutine $package => $subroutine
         => sub { # export the additional functions
	          ; my $here = caller
	          ; my %subs = getglobal($package,'%export')
	          ; foreach my $func (keys %subs)
	              { next if $here->can($func) 
	              ; install Package::Subroutine:: $here => $func =>  $subs{$func}
		           }
	          # create object and send it to the document
	          ; my $obj = $subref->(@_)
             ; $_->broadcast($obj) # should be Juba::Document
	          }
    }

# 
; sub has
    { my $package = caller
    ; my ($sub,%props) = @_
    ; my $subref = $props{'run'} || sub { print "Hallo" }
    ; setglobal($package,'%export',[$sub => $subref])
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
   coreelement 'ks'   # Kindof::Structure is a Juba
                      # Juba Document exports ks
       
   
