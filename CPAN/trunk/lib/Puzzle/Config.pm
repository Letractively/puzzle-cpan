package Puzzle::Config;


use Params::Validate qw(:types);;

use base 'Class::Container';

BEGIN {

	__PACKAGE__->valid_params(
		cornice       => { parse => 'boolean', default => 0, type => BOOLEAN},
		debug		      => { parse => 'boolean', default => 0, type => BOOLEAN},
		cache		      => { parse => 'boolean', default => 0, type => BOOLEAN},
		cornice       => { parse => 'boolean', default => 0, type => BOOLEAN},
		frame_top     => { parse => 'string',  type => SCALAR | UNDEF, default => undef },
		frame_left    => { parse => 'string',  type => SCALAR | UNDEF, default => undef },
		frame_right   => { parse => 'string',  type => SCALAR | UNDEF, default => undef },
		frame_bottom  => { parse => 'string',  type => SCALAR | UNDEF, default => undef },
		base          => { parse => 'string',  type => SCALAR | UNDEF, default => undef },
		gids          => { parse => 'list',   type => ARRAYREF | UNDEF, default => qw/everybody/ },
		login         => { parse => 'string',  type => SCALAR | UNDEF, default => undef },
		namespace		  => { parse => 'string',  type => SCALAR },
		description   => { parse => 'string',  type => SCALAR, default => '' },
		keywords      => { parse => 'string',  type => SCALAR, default => '' },
		db			      => { parse => 'hash',  type => HASHREF},
		traslation    => { parse => 'hash',  type => HASHREF},
		page		  => { parse => 'hash',  type => HASHREF | UNDEF},
		mail		      => { parse => 'hash',  type => HASHREF},
	);
}

# all new valid_params are read&write methods
use HTML::Mason::MethodMaker(
				read_write => [ map { [ $_ => __PACKAGE__->validation_spec->{$_} ] }
				                     keys(%{__PACKAGE__->allowed_params()}) 
																											                     ]
);

sub as_hashref {
	my $self = shift;
	my %ret = map {$_ => $self->{$_}} keys(%{__PACKAGE__->allowed_params()});
	delete $ret{container};
	return \%ret;
}

1;
