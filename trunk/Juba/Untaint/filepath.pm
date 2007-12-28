  package Juba::Untaint::filepath
# ********************************
; our $VERSION='0.01'
# ********************

; use Juba::Untaint
; use CGI::Untaint::object
; use strict; use utf8

# this class is a not worky , but the following
# packages, so they are registered here

; Juba::Untaint->add_submodules
    ( filepath => qw/ filename_strict_ascii / )


; package Juba::Untaint::filename_strict_ascii
# *********************************************
; push our @ISA, 'CGI::Untaint::object'

# only one dot is allowed !!!
; sub _untaint_re 
    { return qr/^(\w+\.?\w{0,6})$/
    }

; 1

__END__



