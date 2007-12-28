; use strict; use warnings; use utf8

# Unter mod_perl is das aktuelle Verzeichnis == '/'
; use lib '/home/ccls22/public_html/perl'
; use lib '/home/ccls22/public_html/perl/lib-cpan'

; sub ok 
    { if($_[0])
        { print "ok"
        }
      else
        { print "not ok"
        }
    ; print " -- @_ " if $_[1]
    ; print "\n"
    }

#; use Cwd ()
#; print Cwd::getcwd,"\n";

; use Juba::Application
; use CGI::Carp 'fatalsToBrowser'

# load Untaint Modules
; use Juba::Untaint::filepath

; print "#<pre>\n"
; print "ok\n"
; print '# $ENV{\'GATEWAY_INTERFACE\'} => ' . "$ENV{'GATEWAY_INTERFACE'}\n"
# ; print "$_ => $INC{$_}\n" for sort { lc($a) cmp lc($b) } keys %INC

; print "# --&gt;".join(" ",@Juba::Untaint::ISA)."&lt;--\n"

; my %mm = Juba::Untaint->_get_modmap
; print "\nmodmap:"
; print "$_ => $mm{$_}\n" for sort { lc($a) cmp lc($b) } keys %mm
; print "\n"

; my $handler = Juba::Untaint->new
    ( file1 => 'ok.ok'
    , file2 => 'nöt.ok'
    )

; ok(  $handler->extract(-as_filename_strict_ascii => 'file1'),$handler->error)
; ok(! $handler->extract(-as_filename_strict_ascii => 'file2'),$handler->error)



#; print "$_ => $INC{$_}\n" for sort { lc($a) cmp lc($b) } keys %INC

; print "#</pre>"

