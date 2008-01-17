  package Juba::Dot
# *****************
; our $VERSION='0.01'
# *******************
; use strict; use warnings

; use Package::Subroutine
; use Package::Subroutine::Functions qw/setglobal getglobal/
  
; sub import
    { my $pkg = shift
    ; export Package::Subroutine:: _ => grep { $pkg->can($_) } @_
    }

; sub coreelement
    { my $package = caller
    ; my ($subroutine,$subref) = @_
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
   coreelement 'dc'
       
   
