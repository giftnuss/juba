  package Juba::Page::Param
# *************************
; our $VERSION='0.01'
# *******************
; use strict; use warnings; use utf8
; use base 'Class::Accessor::Fast'

; __PACKAGE__->mk_accessors
    ( 'params'
    , 'actions' # list of action parameter names
    , 'errors'
    )

; sub new
    { my ($self,$params,$untaint) = @_
    ; my (%params,@errors,@actions)

    ; foreach my $param (@$params)
        { defined($param->untaint($untaint))
            or push @errors, $param->name

        ; push @actions, $param->name if $param->can('action')

        ; $params{$param->name} = $param
        }

    ; bless { params  => \%params
            , errors  => \@errors
            , actions => \@actions
            }, $self
    }

; 1

__END__

=head1 NAME

Juba::Page::Param

=head1 SYNOPSIS

=head1 DESCRIPTION




