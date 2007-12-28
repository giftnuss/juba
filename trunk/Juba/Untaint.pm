  package Juba::Untaint
# *********************
; our $VERSION='0.01'
# *******************
; use strict; use warnings; use utf8

# one of the design goals is to have no much dependicies so 
# I checkout here if this works:
; BEGIN
    { local %INC = %INC
    ; { package UNIVERSAL::require }
    ; $INC{'UNIVERSAL/require.pm'} = '/somwhere/UNIVERSAL/require.pm'
    ; require CGI::Untaint
    ; @Juba::Untaint::ISA = ('CGI::Untaint')
    }

; sub raw_data_value ($$)
    { my ($self,$param) = @_
    ; $self->{__data}->{$param}
    }

; my %real_modules

; sub add_submodules
    { my ($self,$realmodule,@submodules) = @_
    ; local $_
    ; $real_modules{$realmodule} = $realmodule
    ; $real_modules{$_}          = $realmodule for @submodules
    }

; sub _get_modmap { return %real_modules }

# ok, seems to work, so lets overwrite
# register files so one file can serve a lot of cases
# but now I have to preload the files (me is very dumb) :(
; sub _load_module 
    { my $self = shift
    ; my $name     = $self->_get_module_name(shift());
    ; my $realname = $real_modules{$name} || $name

    ; foreach my $prefix 
        ("CGI::Untaint", "Juba::Untaint", 
            (defined($self->{__config}{INCLUDE_PATH}) 
                ? $self->{__config}{INCLUDE_PATH} : ()
            )
        )
        {
        ; my $mod     = "$prefix\::$name"
        ; my $realmod = "$prefix\::$realname"

        ; return $mod if defined $self->{__loaded}{$realmod}

        ; eval 
            { eval "require $realmod" or die "$@\n"
            ; $mod->can('_untaint')   or die "$mod has not an _untaint method.\n"
	    }
        ; unless( $@ )
            { $self->{__loaded}{$realmod} = 1
            ; return $mod
            }
	}
    ; die "Can't find extraction handler for $name.\n$@\n"
    }

; 1

__END__



