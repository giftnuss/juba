# -*- perl -*-

# t/001_load.t - check module loading and basic functionality

; use Test::More tests => 4

; BEGIN { 
        ; package Kasa::Modo
        ; Test::More::use_ok( 'DBIx::Define' )
        
        ; column( sid    => &recid )
        ; column( points => &integer )
        }

; my ($scmn) = DBIx::Define->list_schema_names
; is($scmn,'Kasa','pkg as schema')
  
; my ($table) = DBIx::Define->get_table(name => 'Modo')
; isa_ok($table,'DBIx::Define::Table')
; is($table->name,'Modo',"table name")
  
# als skalar evtl. ein Iterator 
; my @cols = $table->list_columns
; ok(@cols==2)

