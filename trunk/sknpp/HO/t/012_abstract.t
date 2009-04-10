; use strict; use warnings
; use Test::More tests => 4

; BEGIN { use_ok('HO::abstract') }

; { package Abstract::Pkg
  ; eval "use HO::abstract method => qw/this that/"
  }

; ok(!$@,'definition succeeds')

; eval { Abstract::Pkg->this }
; like($@,qr|^Abstract method 'this' called for class Abstract::Pkg\.|)

; my $that = bless {},'Abstract::Pkg'
; eval { $that->that }
; like($@,qr|^Abstract method 'that' called for object of class Abstract::Pkg\.|)