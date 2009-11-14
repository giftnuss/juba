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

use Juba;

my $site = new Juba;
my $p = $site->parameter;

#
# Aktionen
#
my $base = "C:/hvarchiv/apache2.0/Apache2/htdocs/html/";

if( $site->param("fileaction") eq "save" ){
    my $dir = $base.$site->param("dirname");
    if( $site->param("dirname") && !( -d $dir )){
        mkdir $dir;
    }
    my $suff = $site->param("dirname") eq "css" ? ".css" : ".html";
    my $file = $dir."/".$site->param("file").$suff;
    
    if( $site->param("dirname") eq "css" ){
        new Node($site->param("input"))->print_into($file);
    }
    else{
        my $uobj = new Juba::Site('-static');
        if( $site->param("file") ){
            if( $site->param("stylefile") ){
                my $style = new Style()->src( $site->take("juba css pfad").$site->param('stylefile').".css");
                $uobj->head($style);
            }
            
            $uobj->body($site->param("input"));
            $uobj->print_into($file);
        }
    }
}
if( $site->param("fileaction") eq "load" ){
    my $dir = $base.$site->param("dirname");
    my $file = $dir."/".$site->param("file").".html";
    open F, "<$file";
    my $st = join("",<F>);
    my $c = ($st =~ /<link\ rel\=\"stylesheet\"\ href\=\"\/html\/css\/(.*?)\.css/ && $1 );
    my $v = ($st =~ /<body>(.*)<\/body>/sg && $1);
    $site->parameter->{"stylefile"}=$c;
    $site->parameter->{"input"} = $v;
}

if( $site->param("fileaction") eq "cssload" ){
    my $dir = $base.$site->param("dirname");
    my $file = $dir."/".$site->param("file").".css";
    open F, "<$file";
    my $st = join("",<F>);
    $site->parameter->{"input"} = $st;
}

# 
# Das Formular
#
my $f=new Juba::Formular($site);

my $map=new Input()->type("button")->value("Karte")->onClick("location.href='map.pl'");
my $cap=nCaption("HTML lernen mit HTML")->valign("top");
my $tab=nTable(nTr(nTd($f->text)->rowspan(5),
                   nTd($map->style("width:80px;"))->valign("top"),
                   nTd(" ")->style("width: 1em")->rowspan(5),
                   nTd("Stylesheets werden im Ordner css gespeichert")->rowspan(3)->style("width: 80px")),
               nTr(nTd($f->save->style("width: 80px;"))->valign("middle")),
               nTr(nTd($f->saveas->style("width: 80px;"))->valign("middle")),
               nTr(nTd($f->ok->style("width: 80px;"))->valign("middle"),
                   nTd($f->style_select())),
               nTr(nTd($f->clear->style("width: 80px;"))->valign("bottom"),
                   nTd($f->style_laden())->valign("bottom")),
               $cap)->border(0);
               
$f->text->rows(8)->cols(60);

#
# Das Ergebnis
#

my ($one,$two)=new Div()->copy(2);
$one << ($f << $tab );
$two << $site->param("input") unless $site->param("fileaction") eq "cssload";

$site->set_style();
$site->body($one,$two);
$site->print;

