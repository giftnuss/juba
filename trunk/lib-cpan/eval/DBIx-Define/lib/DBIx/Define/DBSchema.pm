  package DBIx::Define::DBSchema
# ******************************
; our $VERSION='0.01'
# *******************
; use strict; use warnings
; use DBIx::DBSchema

# a function that translates a DBIx::Define column to dbschema
# current schema is specified

; sub dbschema_column
    { my ($name,$type,$args) = @{shift}
    ; new DBIx::DBSchema::Column(
	{ name    => $name
	, type    => $type->sqltype
	, null    => $type->sqlnullstr
	, length  => $type->sqlsize
	, default => $type->sqldefault
	, local   => $args
	})
    }

; 1
  
__END__
  
