#!/usr/bin/perl
#!c:/hvarchiv/Perl5.8/bin/Perl.exe

# Datum: 27.1.2004
# Ersteller: Sebastian Knapp <giftnuss@netscape.net>
#
# Projekt: Webeditor
# Version: 0.1
#
# Dies ist freie Software. Sie kann unter den selben Bedingungen wie Perl vertrieben
# und genutzt werden. Für Details lesen die bitte die Datei Artistic.txt
#

; use Juba
; use HO::HTML ( -functional => 1 )

; my $site = new Juba


# 
# Das Formular
#
; my $f=new Juba::Formular($site)

; my $map=
; my $cap=Caption("HTML lernen mit HTML")->valign("top")
; my $tab=Table(Tr(Td($f->text)->rowspan(5),
                   Td($map->style("width:80px;"))),
               Tr(Td($f->save->style("width: 80px;"))->valign("baseline")),
               Tr(Td($f->saveas->style("width: 80px;"))->valign("middle")),
               Tr(Td($f->ok->style("width: 80px;"))->valign("middle")),
               Tr(Td($f->clear->style("width: 80px;"))->valign("bottom")),
               $cap)->border(0);
$f->text->rows(8)->cols(80);

#
# Das Ergebnis
#

my ($one,$two)=new Div()->copy(2);
$one << ($f << $tab );
$two << $site->param("input");

$site->body($one,$two);
$site->print;
