package Puzzle::DBIx::sysMetaschema;

use base qw(Puzzle::DBI);

__PACKAGE__->table('sysMetaschema');

__PACKAGE__->columns(All => qw/	
																cod_columnname txt_label
															/);

*label = \&txt_label;

1;
