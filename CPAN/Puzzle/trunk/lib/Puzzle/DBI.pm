package Puzzle::DBI;

use vars '$VERSION';

use base 'DBIx::Class::Schema';

use Puzzle::Loader;



our $VERSION = '0.01';

sub new {
    my $proto   = shift;
    my $class   = ref($proto) || $proto;
	my $dsn = shift;
	my $user = shift;
	my $password = shift;
    my $s       = Puzzle::Loader->connect($dsn,$user,$password);
    bless $s, $class;
    return $s;
}

#sub AUTOLOAD {
#	my $s = shift;
#	my $table = $AUTOLOAD;
#	$table =~ s/.*:://;
#	return $s->resultset($table);
#}

1;

