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

sub row2hash {
	my $selft	= shift;
	my $rs      = shift;
	return {map { $rs->table.'.'.$_ => $rs->get_column($_) } $rs->columns};
}

sub rs2aoh {
	my $self	= shift;
    my $rs      = shift;
    my @ret;
    while (my $row = $rs->next) {
        push @ret, $self->row2hash($row);
    }
    return \@ret;
}

1;
