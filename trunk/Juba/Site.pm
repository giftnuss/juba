  package Juba::Site
; use base 'HO::Structure'


; sub new
    { my $class=shift
    ; my $tab=Table(Caption("HTML lernen mit HTML")->valign("top"))
    ; my @tr=Tr()->copy(3)

    ; my @r1=Td()->copy(6)
    ; my @r2=Td()->copy(3)
    ; $r2[0]->colspan(4)
    ; my $tda=Td()->colspan(6)
      
    ; my $self=$class->SUPER::new()
    ; $self->set_root($tab)

    ; $tr[0] << \@r1
    ; $tr[1] << \@r2
    ; $tr[2] << $tda
    ; $tab << $_ for @tr
    
    ; $self->set_area("btn$_",$r1[$_-1]) for 1..6
    ; $self->set_area("stylef$_",$r2[$_-1]) for 1..3
    ; $self->set_area("input",$tda)
    
    ; $self
    }

; sub set_file_actions
    { my ($site,$form)=@_
    ; my $map=JC->take('juba button map')
    ; my @mn =map { $form->$_ } qw/save saveas ok reset clear/
    ; unshift @mn, $map
    ; for ( 1..6 )
        { $site->fill("btn$_",$mn[$_-1]->style("width: 80px;")) }
    }
    
; sub set_style_actions
   { my ($site,$form)=@_
   ; $site->fill("stylef1",$form->style_select)
   ; $site->fill("stylef2",$form->style_load->style("width: 80px;"))
   ; $site->fill("stylef3",$form->style_apply->style("width: 80px;"))
   }
     
; sub set_input
   { my ($site,$form)=@_
   ; $site->fill('input',$form->text->rows(8)->cols(80))
   }

; 1

__END__

