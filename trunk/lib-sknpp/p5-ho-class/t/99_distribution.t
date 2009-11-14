         
use strict;	 
use Test::More;
	 
BEGIN { eval { require Test::Distribution; die 'works not well here' };
        
	if($@) { plan skip_all => 'Test::Distribution not installed';
               }
	else { import Test::Distribution; }
      }
     
     

