
; use strict

; use warnings

; package HO::HTML::Input

; use HO::HTML
; use HO::Exporter
; our @ISA=('HO::Tag::Single','HO::Exporter');

; our $VERSION = '0.0.1'
; our @EXPORT
; our %defined

; sub new
    { my ($class,@arg)=@_
    ; $class = ref $class if ref $class
    ; my $self = bless new Input(@_) , $class
    ; $self->type(lc $class)
    }

; sub import
    { my $class=shift
    ; my %p=( namespace => '', functional => 0, @_)
    ; my $ns=$p{namespace}; $ns.='::' if $ns 
    ; 
    ; my @packages = qw(Radio Text Checkbox Hidden IButton)
    ; foreach ( @packages )
        { my $pack="${ns}$_"
        ; $class->register(\@EXPORT, $_, $pack ) if $p{functional}
        ; next if $defined{$pack}
        ; my $type=lc
        ; $type=substr($type,1) if $type eq 'ibutton'
        ; eval qq~ package $pack; our \@ISA=qw(${ns}Input)
                 ; sub new { shift()->SUPER::new()->type("$type") }
                 ~
        ; $defined{$pack}++
        }
    }
    
; 1

__END__

=head1 NAME

HO::HTML::Input

=head1 SYNOPSIS
