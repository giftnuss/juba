; use strict; use warnings; use utf8

; BEGIN 
    { my $here = [caller(0)]->[1] =~ /(.*)\// && $1 || '.'
    ; eval "use lib '$here','$here/lib-cpan'"
    }

; use Juba::Application
; use CGI::Carp 'fatalsToBrowser'

; use Sliced::Bread

; print "ok\n"

; sub ok 
    { if($_[0])
        { print "ok"
        }
      else
        { print "not ok"
        }
    ; print " -- $_[1]" if $_[1]
    ; print "\n"
    }

; ok($Sliced::Bread::ISA[0] eq 'Juba::Application')

; my @pages = Sliced::Bread->pages
; ok(0+@pages == 4,Sliced::Bread->pages)


; Sliced::Bread->dispatch()

