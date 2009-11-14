#!/usr/bin/perl

; use File::Find

; my @erg
; sub wanted
    { push @erg,$File::Find::name }
    
; find( \&wanted, '.' )

; print "$_\n" for @erg
