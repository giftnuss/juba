  use Juba::Application
# Unter mod_perl is das aktuelle Verzeichnis == '/'
; use lib '/home/ccls22/public_html/perl'
; use lib '/home/ccls22/public_html/perl/lib-cpan'
; use lib '/home/ccls22/sknpp/basis/lib'

; use CGI::Carp 'fatalsToBrowser'

; use Sliced::Bread
; use strict

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

