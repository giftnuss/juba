; use strict; use warnings; use utf8

; BEGIN 
    { my $here = [caller(0)]->[1] =~ /(.*)\// && $1 || '.'
    ; eval "use lib '$here','$here/lib-cpan'"
    }

; use Juba::Application
; use CGI::Carp 'fatalsToBrowser'

; BEGIN
    { sub ok 
        { if($_[0])
            { print "ok"
            }
          else
            { print "not ok"
            }
        ; print " -- @_ " if $_[1]
        ; print "\n"
        }
    }


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

