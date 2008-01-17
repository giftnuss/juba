#!/usr/bin/perl

; use lib 'lib-cpan'
; use Package::Subroutine::Functions qw/setglobal/ 

; use constant SERVER => 'HTTP::Server::Singlethreaded'
  
; BEGIN
  { my %static = ('/' => './')
  ; setglobal(SERVER,'%Static',[%static])
	
  ; setglobal(SERVER,'@Port',[8091])
  ; setglobal(SERVER,'$Timeout',5)
  }

; my $QUITVAR

; use HTTP::Server::Singlethreaded function 
    => { '/time/' => sub { "Content-type: text/plain\n\n".localtime }
       , '/quit/' => sub { $QUITVAR=1 } 
       }

; Serve() while !$QUITVAR
  
