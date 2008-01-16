  package Package::Subroutine::Ensure
# ***********************************
; our $VERSION='0.01'
# *******************
  
; require 'Exporter'
  
; our @ISA = ('Exporter')
; our @EXPORT_OK = qw/
     ensure_arrayref
     setglobal
   /
  
; sub ensure_arrayref
  { return map { ref eq 'ARRAY' ? $_ : [$_] } @_
  }

; sub setglobal
   { my ($pkg,$vars,$values) = ensure_arrayref(@_[0,1,2])
   ; my $alternatives        = $_[3] || {}
   ; my $setter = { '@' => sub { push @{$varname},@_ }
	          , '$' => sub { (${$varname}) = @_ }
	          , '%' => sub { %{$varname} = @_ }
	          , '&' => sub { *{$varname} = shift }
                  , %$alternatives
                  }
	     
   ; foreach my $package (@$pkg)
       { foreach my $var (@$vars)
           { my $type = substr($var,0,1)
	   ; my $name = substr($var,1)
	   ; my $varname = join('::',$package,$name)
	   ; $setter->{$type}->(@$values)
	   }
       }
   }

; 1
  
__END__
  
=head1 NAME

Package::Subroutine::Functions

=over 4

=item C<ensure_arrayref> 

Ensure that each argument is a array reference.

=back
