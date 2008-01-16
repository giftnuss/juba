  package Juba::Application
# *************************
; our $VERSION='0.01'
# *******************
; use Sub::Uplevel

; use Exporter ('import')

; our @EXPORT = ('page')

; use Carp
; use CGI

# remove this
# <<<<
; use lib '/home/ccls22/sknpp/HO/lib'
; use lib '/home/ccls22/sknpp/Package-Subroutine/lib'
# >>>>

; use lib 'lib-cpan/'
; use lib 'lib-cpan/Hash-Path/lib/'

; use lib 'Recipe/lib/'

# load cgi::Untaint but overwrite plugin loading mechanism.
; use Juba::Untaint

; sub pages { carp 'abstract method "pages" called!' }

; sub dispatch
    { my $self = shift
    ; my ($name,$class) = ($self->pages)[0,1]
    ; eval "require $class" or die $@

    ; my $page = $class->new(pagename => $name)
    ; $page->action()
    ; $page->display()
    }

; sub cgi { CGI->new }

; 1

__END__

=head1 NAME

Juba::Application

=head1 SYNOPSIS

      package Sliced::Bread;
      use base 'Juba::Application';

      sub pages { 
          ( webeditor => 'Sliced::Bread::Site::WebEditor'
          , wizard    => 'Sliced::Bread::Site::Wizard'
          )
      }

      # in a script say
      use Sliced::Bread;
      Sliced::Bread->dispatch();

=head1 DESCRIPTION

Base class for a simple web application.

It is not used to create objects. Some methods have to be overwritten other 
methods provides sensesable defaults.

=head2 C<pages>

This is an abstract method here. The function in the descandened class should
return a list of key value pairs where the key is a one word name for the
page and the value is the class which should be used to create the page object.
This class is usualy a subclass of C<Juba::Page>

So one class is able to create different pages. When the page object is 
constructed the name is used as the only argument for the constructor.





 
