
; my @args

; BEGIN
    { eval { require Test::MinimumVersion; }
    ; if( $@ )
        { push @args, skip_all => "Test::MinimumVersion is not installed!"
        }
      else
        { push @args, tests => 3
        }
    }

; use Test::More @args

; Test::MinimumVersion::minimum_version_ok('lib/HO/class.pm', '5.006')
; Test::MinimumVersion::minimum_version_ok('lib/HO/accessor.pm', '5.006')
; Test::MinimumVersion::minimum_version_ok('lib/HO/abstract.pm', '5.006')