  package Juba::Page
# ******************
; our $VERSION='0.01'
# *******************
; use strict; use warnings; use utf8
; use base 'Class::Accessor::Fast'

; __PACKAGE__->mk_accessors
    ( 'pagename'
    , 'params'
    , 'cgi'
    , 'untaint'
    )

; use Package::Subroutine

; use Juba::Param        # represents a single param
; use Juba::Page::Param  # represents the params for a page

; sub import
    { export Package::Subroutine _ => ([_paramdef => 'param'])
    }

######################
# exported functions
######################
; sub _paramdef
    { my $name = shift
    ; my %args = %{shift()}
    ; my $package = caller

    ; my $class
    ; unless( $class = delete($args{'class'}) )
        { $class = $package->_get_param_class(\%args)
        }

    ; $args{'name'} = $name
    ; my $param = $class->new(\%args)

    ; { no strict 'refs'
      ; push @{join('::',$package,'PARAMS')},$param
      }

    }

# protected helper
; sub _get_param_class
    { my ($self,$args) = @_
    ; my $class
    ; if(defined $args->{'action'})
        { $class = 'Juba::Param::Action'
        }
      else
        { $class = 'Juba::Param::Data'
        }
    ; $class
    }

#####################
# object interface
#####################
; sub new
    { my ($self,%args) = @_

    ; $args{'cgi'} ||= Juba::Application::cgi()
    ; my $handler = Juba::Untaint->new($args{'cgi'}->Vars)

    ; my @params
    ; { no strict 'refs'
      ; @params = @{join('::',$self,'PARAMS')}
      }

    ; my $page = bless 
        { 'pagename' => $args{'pagename'}
        , 'params'   => Juba::Page::Param->new(\@params,$handler)
        , 'cgi'      => $args{'cgi'}
        , 'untaint'  => $handler
        } , $self
    }

; sub get_param
     { return $_[0]->params->params unless defined $_[1]
     ; return $_[0]->params->params->{$_[1]}
     }

###########################
# Process steps
###########################
; sub action
    { my ($obj) = @_
    ; my @actions = @{$obj->params->actions}
    ; foreach my $actionparam ( map {print "$_"; $obj->get_param($_) } @actions)
        { if($actionparam->is_valid)
            { $actionparam->action->{$actionparam->value}->($obj); print "OK"
            }
        }
    }

; sub display
    { use Data::Dumper
    ; print "<pre>"
    ; print Dumper($_[0])
    ; print "</pre>"
    }

; 1

__END__

=head1 NAME

Juba::Page

=head1 SYNOPSIS

   package CGI::Project::Sites::Whatever;

   use basis 'Juba::Page';

   param( 'fileaction'
       => { action
           => { save => sub { ... }
              , load => sub { ... }
              }
          })

   param( 'file' 
       => { untaint_as => filename_strict_ascii });


