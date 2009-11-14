#!/usr/bin/perl

; use strict

; use Juba
; use File::Find
; use File::Basename
; use HO::HTML ( functional => 1 )

; my $site = new Juba
; print CGI::header

#
# Aktionen
#

; my @htmlfiles
; sub list_html_files
    { my $dir  =$site->take("juba base dir")
    ; my $dirr =quotemeta "$dir/"
    ; my $wanted=sub 
         { return unless /\.html$/
         ; my $file=$File::Find::name
         ; $file =~ s/$dirr//
         ; my ($f,$d)=fileparse($file,'\.html')
         ; chop $d
         ; push @htmlfiles, [$f,$d]
         }
    ; find( $wanted, $dir )
    ; wantarray ? @htmlfiles : \@htmlfiles
    }

; my $sct = $site->take("juba script main")
; my $bgs = $site->take("juba script bgs")
    
; my $pat = "$sct?file=%s\&dirname=%s\&fileaction=load"
; my $tab = Table()->cellpadding(4);

; my $dir2=''
; foreach my $f ( list_html_files() )
    { my ($file,$dir)=@$f;
    ; my $link1=A($file)->href(sprintf($pat,$file,$dir))
    ; my $link2=A(" ==&gt; ")->target('_new')
                ->href(join "/",$site->take("juba base path")
                               ,$dir,"$file.html")
    ; $tab << Tr( Td( $dir2 ne $dir ? $dir : '' ), Td( $link1 ), Td( $link2 ))
    }

; $site->body(A(" NEU ")->href($sct)," ",
             # A(" HINTERGRUND ")->href($bgs),
              $tab)
; print "$site"
