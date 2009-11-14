; package HO::print

=head1 NAME

HO::print - Output methods for Hierarchical Objects
  
=head1 SYNOPSIS

This Module adds two output methods to HO.

  use HO::print

  # build up a HO structure

  $obj->print; # sends output to STDOUT

  $obj->print_into('file.html'); # or a file

=cut

; our $VERSION='0.0.1'

; use HO
; use Carp

; package HO

; sub print
    { print $_[0]->get }
  
; sub print_into
    { my ($obj,$file)=@_
    ; eval
        { open TARGET,">$file" or die "$^E"
        ; my $old=select TARGET
        ; $obj->print
        ; select $old
        ; close TARGET or die "$^E"
        }
    ; (my $error=$@) or return        
    ; my $errormsg="Something is wrong with print_into file $file!\n$error"
    ; carp $errormsg
    ; return $errormsg
    }
  
; 1
  
__END__
