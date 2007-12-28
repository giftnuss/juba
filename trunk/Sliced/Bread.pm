  package Sliced::Bread
# **********************
; our $VERSION='0.01'
# *******************
; use basis 'Juba::Application'

#; @Sliced::Bread::ISA = ('Juba::Application') 

; sub pages
    { ( webeditor => 'Sliced::Bread::Site::WebEditor'
      , wizard    => 'Sliced::Bread::Site::Wizard'
      )
    }

; 1

__END__
