  use t::Test::Juba
  ; use Test::More tests => 6
  ; BEGIN { use_ok('Juba::Param') }
  
  ; my $p = Juba::Param->new
  ; isa_ok($p,'Juba::Param')
  ; ok($p->can('name')
  ; ok($p->can('raw_value')
  ; ok($p->can('value')
  ; ok($p->can('untaint_as')