# Datum: 2005-09-12
#
# Ersteller: Sebastian Knapp <giftnuss@netscape.net>
#
# Projekt: Webeditor
# Version: 0.3
#
# Dies ist freie Software. Sie kann unter den selben Bedingungen wie Perl 
# vertrieben und genutzt werden. Für Details finden sie in den Dokumenten 
# Artistic.txt oder GPL.
#

; use strict
; use lib 'lib'

; package JC
; use Chest::Global
; our @ISA=qw(Chest::Global)

; package Juba;
; our @ISA = qw /HO::HTML::Document/;

; BEGIN
  { use HO::HTML::Document
  ; use HO::print
  }

# import <-> header <-> param <-> path_info <-> redirect <-> script_name 
; use CGI ':cgi'       
; use CGI::Carp 'fatalsToBrowser'  

; use Juba::Parser
  
; sub new
    { my $obj = bless new HO::HTML::Document() , $_[0]
    ; $obj->NoCache()
    ; $obj->init()
    ; $obj->untaint_param(qr/^([\w\-][\w\-\.]*)$/,'file')
    ; $obj->untaint_param(qr/^([\w\-][\w\-\.]*)$/,'stylefile')
    ; $obj->untaint_param(qr/^([\w\-][\w\-\/]*)$/,'dirname')
    ; return $obj
    }
    
; sub untaint_param
    { my $obj=shift
    ; my $re =shift
    ; foreach ( @_ )
        { my $key=$_
        ; my $val=param($key) or next
        ; if( $val =~ $re )
            { $val = $1 }
          else
            { $obj->error("Wrong parameter for '$key'!")
            ; $val=''
            }
        ; param( -name => $key, -value => $val )
        }
    }

; sub take 
    { my ($obj,$str,@arg)=@_
    ; JC->take($str,$obj,@arg)
    }
    
; sub init
    { my $s=shift
    ; my %o = 
       ( "juba base path" => "/~trixom/juba"
       , "juba base dir"  => "/home/trixom/public_html/juba"
       , "juba css path"  => "/~trixom/css"
       , "juba css dir"   => "/home/trixom/public_html/css"
       
       , "juba script main" => '3.pl'
       , "juba script map"  => 'map.pl'
       , "juba script bgs"  => 'bgs.pl'
      
       , "juba button map" => Input->new()->type("button")->value("Karte")
                                          ->onClick("location.href='map.pl'")
       , "juba error"     => new Div()->style('color: red')
       )
    ; sub ms{ my $v = $_[0]; return sub () {$v} }
    ; foreach ( keys %o )
      { JC->insert($_,sub{ms($o{$_})}) }
    }
    
; sub error 
    { my $obj=shift
    ; my $error=$obj->get_attribute('error') || []
    ; push @$error, @_
    ; $obj->set_attribute('error',$error)
    }
    
; sub get
    { my $obj=shift
    ; my $ew =$obj->take("juba error")
    ; my $er =$obj->get_attribute('error')
    ; $obj->body( $ew->insert(join('<br />',@$er)) ) if $er
      
    ; $obj->set_style()
    ; $obj->set_title()
    ; $obj->SUPER::get
    }      

; sub set_style
    { my $obj = shift
    ; if( my $stylefile=param('stylefile') )
       { my $style = HO::HTML::Document::Style->new()
                     ->src( $obj->take("juba css path")."/$stylefile.css" )
       ; $obj->head($style)
       }
    }

; sub set_title
    { $_[0]->title(param("titel")) }
    
; sub juba_file
    { my $obj=shift
    ; my $dir = $obj->take("juba base dir")."/".param("dirname")
    ; if( param("dirname") && !(-d $dir ) )
        { mkdir $dir }
    ; $dir."/".param("file").".html"
    }

; sub juba_css_file
    { my $obj=shift
    ; my $dir = $obj->take("juba css dir")
    ; $dir."/".param("file").".css"
    }
    
; sub juba_save
    { my ($obj,$uobj,$file)=@_
    ; if( my $content=param("input") )
        { my $err=$uobj->print_into($file)
        ; $obj->error($err) if $err
        }
    }
    
; sub save_file
    { my $obj=shift
    # TODO: Complete unsafe!!!
    ; my $file=$obj->juba_file 
    ; my $uobj = new Juba()
    # CSS & Titel
    # ; $uobj->set_style
    # ; $uobj->set_title
    # content
    ; $uobj->body(param('input'))
      
    ; $obj->juba_save($uobj,$file) 
    }
    
; sub save_css_file
    { my $obj=shift
    # TODO: Author
    ; my $file=$obj->juba_css_file
    ; my $uobj=new HO(param('input'))
    ; $obj->juba_save($uobj,$file)
    }
      
; sub _load_file
    { my ($obj,$file)=@_
    ; my $text=''
    ; eval
        { open F, "<$file" or die "$^E"
        ; $text = join("",<F>)
        ; close F or die "$^E"
        }
    ; my $err=$@
    ; $obj->error("Can not load file $file!\n$err") if $err
    ; $text
    }
    
; sub load_file
    { my $obj=shift
    ; my $file=$obj->juba_file
    ; my $text=$obj->_load_file($file)
    ; my $fo=new Juba::Parser($text)
    ; param(-name => "input",     -value => $fo->input)
    ; param(-name => "stylefile", -value => $fo->stylefile)
    ; param(-name => "titel",     -value => $fo->title)
    }
    
; sub load_css_file
    { my $obj=shift
    ; my $css=$obj->juba_css_file
    ; my $text=$obj->_load_file($css)
    ; param( -name => 'input', -value => $text )
    }
    
; sub AUTOLOAD
    {	my $self=shift
	  ; our $AUTOLOAD =~ s/.*:://
    ; $self->error("Juba - Unknown method: $AUTOLOAD")
    }

###############################
; package Juba::Formular
###############################
; our @ISA=qw/HO/
    
; use HO::HTML        ( functional => 1 )
; use HO::HTML::Input ( functional => 1 )
    
; sub new
    { my ($obj,$site,$action)=@_;
    ; my $class = ref $obj || $obj;
    ; $action ||= CGI::script_name
    
    ; my $form   = Form()->name("jubaf")->action($action)->method('post')
    ; my $text   = Textarea()->name("input")->insert(CGI::param("input"))
    ; my $save   = IButton()->value("sichern")->onClick("jbsave(this)")
    ; my $saveas = IButton()->value("sichern als")->onClick("jbsaveas(this)")
    ; my $style1 = IButton()->value("CSS laden")->onClick("edit_style(this)")
    ; my $style2 = IButton()->value("Titel")->onClick("set_title(this)")
    ; my $clear  = IButton()->value("löschen")->onClick("clear_txtf(this)")

    ; my $sa     = Hidden()->name("fileaction")->value("")
    ; my $title  = Hidden()->name("titel")->value(CGI::param("titel"))
    ; my $dir    = Hidden()->name("dirname")->value(CGI::param("dirname"))
    ; my $file   = Hidden()->name("file")->value(CGI::param("file"))
    ; my $user   = Hidden()->name("user")->value(CGI::param("user"))
    ; my $num    = Hidden()->name("num")->value(CGI::param("num"))

    ; my $ok     = Input()->type("submit")->value("ok")
    ; my $reset  = Input()->type("reset")->value("reset")
          
    ; my $self = bless 
          { elem => new HO($form<<$user<<$num<<$dir<<$file<<$sa<<$title),
            form => $form, save => $save, saveas => $saveas,
            ok   => $ok, 'reset' => $reset, text => $text ,
            style_load => $style1, style_apply => $style2 ,
            clear => $clear , site => $site },$class
    ; $self->js()
    ; $self
    }

; sub insert{ my ($o,@a)=@_;$o->{'form'}->insert(@a); }
; sub get{ $_[0]->{'elem'}->get(); }
    
; sub AUTOLOAD
    {	my $self=shift
	  ; our $AUTOLOAD =~ s/.*:://
    ; $self->{$AUTOLOAD}
    }

; sub js{
    my ($obj) = @_;
    my $site = $obj->{'site'};
    
    $site->script( <<"TEXT" );

function jbsaveas( o ){
    var f=o.form;
    f.dirname.value="";
    f.file.value="";
    jbsave( o );
}

function jbsave( o ){
    var f=o.form;
    var dir = f.dirname.value;
    var file= f.file.value;
    
    if( dir == "" ){
        dir = get_dir();
    }
    if( file == "" ){
        file = get_file();
    }
    if( dir && file ){
        f.dirname.value = dir;
        f.file.value = file;
        f.fileaction.value = "save";
        if( dir == "css" ) f.fileaction.value = "savecss";
    }
    else{
        alert("Nicht gespeichert!");
    }
    f.submit();    
}

function get_dir(){
    pr = "Geben sie bitte den Ordnernamen ein.\\n " +
         "Nur Buchstaben und Zahlen sind zulässig.\\n " +
         "Ein Style kann im Ordner \\"css\\" gespeichert werden. ";
    return tested(pr);
}
function get_file(){
    pr = "Geben sie bitte den Dateinamen ein.\\n " +
         "Nur Buchstaben und Zahlen sind zulässig.";
    return tested(pr);
}

function tested(pr){
    f = true;
    var name;
    
    var expr = /^\\w+\$/;
    while( f ){
        name = prompt(pr,"");
        if( name == "" ){       
            f=false;
        }
        if( expr.test(name) ){
            f=false;
        }
        if( name.length > 15 ){
            f=true;
        }
    }
    return name;
}

function edit_style( o ){
    var f = o.form;
    
    var file=f.stylefile.options[f.stylefile.selectedIndex].value;
    
    if( file ){
        f.file.value = file;
        f.fileaction.value = "loadcss";
    }
    else{
        alert("Kein Style ausgewählt!");
    } 
    f.submit();
}

function clear_txtf( o ){
    var f = o.form;
    f.input.value="";
}  

function set_title(f){
    t=prompt("Bitte geben Sie den Titel der Seite an.");
    f.form.titel.value=t;
    f.form.submit();
}

TEXT
    
}

; sub style_select
    { my $obj = shift
    ; my $dir  = JC->take("juba css dir")

    ; my $sel = Select( Option("- Style -")->value("") )->name("stylefile")
    ; eval
        { opendir( DIR , $dir ) or die "$^E"
        ; foreach ( readdir DIR )
            { next unless /(.*)\.css$/
            ; my $css=$1
            ; my $o=Option($css)->value($css) << "\n"
            ; $o->selected if $css eq CGI::param("stylefile")
            ; $sel << $o
            }
        ; closedir DIR or die "$^E"
        }
    ; if( my $err=$@ )
        { $obj->site->error("List style directory failed!\n$err") }
    ; return $sel;
    }

; package Juba::Site
; use HO::Structure
; use base 'HO::Structure'

; use HO::HTML functional => 1

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
   
; "giftnuss"
    
__END__
