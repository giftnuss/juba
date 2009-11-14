
; use strict
; use warnings

; package HO::HTML
; use HO::Tag
; use HO::Exporter
; our @ISA=qw(HO::Exporter)

; our $VERSION='0.2.1'
; our @EXPORT

; our %packages = (
     'HO::Tag::Double'
       => [qw(Html Head Title Body
              A Big Div P Pre Small Span Sub Sup
              Caption Colgroup Col Table Thead Tbody Tfoot Tr Th Td
              Ol Ul Li Dl Dd Dt
              Blockquote Q
              Button Fieldset Form Label Legend Option Select Textarea 
          )],
     'HO::Tag::Single'
       => [qw(Base Br Hr Img Input Link Meta)],
     'HO::Tag::Double::Suffix'
       => [qw(H)],
     'HO::Tag::Double::Letter'
       => [qw(Bold Italic)]
     )

; sub import
   { my $class=shift
   ; my %p=( namespace => '', functional => 0, @_)
   ; my $ns=$p{namespace}; $ns.='::' if $ns
   ; our (%packages,%defined,@EXPORT)
   ; 
   ; foreach my $base ( keys %packages )
      { foreach ( @{$packages{$base}} )
         { my $pack=${ns}.$_
         ; $class->create_tag($pack,$base,lc)
         ; $class->register( \@EXPORT, $_, $pack ) if $p{functional}
         }
      }
   }

;

; 1

__END__

=head2 TODO



Selten genutzte Tags in extra Package

# Phrase elements: EM, STRONG, DFN, CODE, SAMP, KBD, VAR, CITE, ABBR, and ACRONYM

# # Quotations: The BLOCKQUOTE and Q elements

# Image Maps: Map Area

# Marking document changes: The INS and DEL elements

# Multimedia: Applet

# I18n: BDO


In HTML, there are two types of hyphens: the plain hyphen and the soft hyphen. The plain hyphen should be interpreted by a user agent as just another character. The soft hyphen tells the user agent where a line break can occur.

Those browsers that interpret soft hyphens must observe the following semantics: If a line is broken at a soft hyphen, a hyphen character must be displayed at the end of the first line. If a line is not broken at a soft hyphen, the user agent must not display a hyphen character. For operations such as searching and sorting, the soft hyphen should always be ignored.

In HTML, the plain hyphen is represented by the "-" character (&#45; or &#x2D;). The soft hyphen is represented by the character entity reference &shy; (&#173; or &#xAD;)

=cut
