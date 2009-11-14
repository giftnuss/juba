#!/usr/bin/perl

; use strict
; use Juba

; my $site = new Juba

; print CGI::header()

; my $DEBUG=0
#
# Aktionen
#
; if( $DEBUG )
    { $site->error(sprintf("fileaction:'%s'",CGI::param('fileaction'))) 
    ; $site->error(sprintf("dirname:'%s'",CGI::param('dirname'))) 
    ; $site->error(sprintf("file:'%s'",CGI::param('file'))) 
    ; $site->error(sprintf("stylefile:'%s'",CGI::param('stylefile'))) 
    }
  
; if( CGI::param("fileaction") eq "save" )
      { $site->save_file }
  elsif( CGI::param("fileaction") eq "load" )
      { $site->load_file }
  elsif( CGI::param("fileaction") eq "savecss" )
      { $site->save_css_file }
  elsif( CGI::param("fileaction") eq "loadcss" )
      { $site->load_css_file }
  
# 
# Das Formular
#
; use HO::HTML        ( functional => 1 )
; use HO::HTML::Input ( functional => 1 )
; my $f=new Juba::Formular($site)
; my $s=new Juba::Site()
  
; $s->set_file_actions($f)
; $s->set_style_actions($f)
; $s->set_input($f)

#
# Das Ergebnis
#

; my ($one,$two)=Div->new()->copy(2);
$one << ($f << $s );
$two << CGI::param("input");

$site->body($one,$two);

; print "$site"
