  package Juba::Application
# *************************
; use Sub::Uplevel
; use strict; use warnings
; our $VERSION='0.01'
# *******************

; use Carp ()
; use CGI ()

; BEGIN
    { my @sknpp_libs = ('HO','Package-Subroutine')
    ; my $here = [caller(0)]->[1] =~ /(.*)\/Juba/ && $1
    ; my @load = map { "'$here/sknpp/$_/lib'" } @sknpp_libs

    ; eval "use lib ".join(',',@load)
    }

# load cgi::Untaint but overwrite plugin loading mechanism.
; use Juba::Untaint

; sub pages { Carp::carp 'abstract method "pages" called!' }

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





 
