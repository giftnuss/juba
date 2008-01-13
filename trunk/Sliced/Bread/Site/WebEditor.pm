  package Sliced::Bread::Site::WebEditor
# ***************************************
; our $VERSION='0.01'
# *******************

; use basis 'Juba::Page'

; use Juba::Untaint::filepath

; param( 'fileaction'
    => { action =>
            { 'save' => sub 
		    {  
		    ; print "save" 
		    }
            , 'load' => sub 
		    { 
		    ; print "load" 
		    }
            , 'loadcss' => sub { print "loadcss" }
            , 'savecss' => sub { print "savecss" }
            }
       })

; param( 'file'
    => { untaint_as => 'filename_strict_ascii' } )

; param('stylefile'
    => { untaint_as => 'filename_strict_ascii' } )

; 1

__END__


