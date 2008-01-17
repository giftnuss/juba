  package Test::Juba
# ******************
; our $VERSION='0.01'
# *******************
; use Juba::Application
  
; use strict; use warnings; use utf8
  
; sub import
  { local $_
  ; $_->import for qw/strict warnings utf8/ 
  }

; 1
  
__END__
  
=head1 NAME

Test::Juba
  
=head1 SYNOPSIS

    # first code line in your test file   
    use t::Test::Juba
  
=head1 DESCRIPTION

This modul provides a central point for customization of the testing
environment.
  
It exports the pragmas C<strict>, C<warnings> and C<utf8> in the testfile.
  
