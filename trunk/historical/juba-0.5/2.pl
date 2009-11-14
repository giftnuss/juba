#!/usr/bin/perl

; use Juba

; my $site = new Juba

; print CGI::header()

#
# Aktionen
#
; if( CGI::param("fileaction") eq "save" )
  { $site->save_file }
; if( CGI::param("fileaction") eq "load" )
  { $site->load_file }
; if( CGI::param("fileaction") eq "savecss" )
  { $site->save_css_file }
  
# 
# Das Formular
#
; use HO::HTML        ( functional => 1 )
; use HO::HTML::Input ( functional => 1 )
; my $f=new Juba::Formular($site)

; my $map=$site->take("juba button map")
  
; my $cap=Caption("HTML lernen mit HTML")->valign("top")
; my $tab=Table(Tr(Td($f->text)->rowspan(5),
                   Td($map->style("width:80px;"))),
               Tr(Td($f->save->style("width: 80px;"))->valign("baseline")),
               Tr(Td($f->saveas->style("width: 80px;"))->valign("middle")),
               Tr(Td($f->ok->style("width: 80px;"))->valign("middle")),
               Tr(Td($f->clear->style("width: 80px;"))->valign("bottom")),
               $cap)->border(0)
; $f->text->rows(8)->cols(80)

#
# Das Ergebnis
#

; my ($one,$two)=Div->new()->copy(2);
$one << ($f << $tab );
$two << CGI::param("input");

$site->body($one,$two);

; print "$site"
