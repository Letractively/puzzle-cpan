package Puzzle::Debug;

use base 'Class::Container';

use Data::Dumper;
use HTML::Entities;
use Time::HiRes qw(gettimeofday tv_interval);



use HTML::Mason::MethodMaker(
	read_only 		=> [ qw(timer) ],
);

sub timer_reset {
	my $self	= shift;
	$self->{timer} = [gettimeofday];
}

sub internal_objects_dump_for_html {
	my $self		= shift;
  my $glob		= $self->all_mason_args_for_debug;
  my %debug;
  my $to_dump = sub { $_[0] =~ s/^\$VAR1\s*=\s*//;
                      $_[0] =~ s/(\'pw\'\s*\=\>\s*\'[^']+)/'pw' => '********/;
                      $_[0] = encode_entities($_[0]);
                      $_[0] =~ s/\n/<br>/g;
                      $_[0] =~ s/\s/&nbsp;/g;
                      return $_[0]};
	$debug{debug_elapsed}	= tv_interval($self->timer);
  foreach my $key (qw/conf post args session env/) {
		delete $glob->{$key}->{container};
    foreach (sort {lc($a) cmp lc($b)} keys %{$glob->{$key}}) {
      my $dumper = &$to_dump(Data::Dumper::Dumper($glob->{$key}->{$_}));
      push @{$debug{"debug_$key"}},{ key => $_,value =>  $dumper};
    }
  }
  foreach (keys %{$self->container->post->args}) {
      my $dumper = &$to_dump(Data::Dumper::Dumper($self->container->post->args->{$_}));
      push @{$debug{"debug_http_post"}},{ key => $_,value =>  $dumper};
  }
  push @{$debug{"debug_cache"}}, {key => 'size',
    value => $self->container->_mason->cache(namespace=>$self->container->cfg->namespace)->size};
  my @cache_keys =$self->container->_mason->cache(namespace=>$self->container->cfg->namespace)->get_keys;
  foreach (@cache_keys) {
    push @{$debug{"debug_cache"}},
      {key => $_, value => &ParseDateString("epoch " .
        $self->container->_mason->cache(namespace=>$self->container->cfg->namespace)->get_object($_)->get_expires_at())};
  }
  return %debug
}

sub all_mason_args {
	# ritorna tutti i parametri globali
	# alcuni normalizzati
	my $self	= shift;
	return { %{$self->container->cfg->as_hashref}, 
		%{&_normalize_for_tmpl(&_normalize_for_tmpl(&_normalize_for_tmpl($self->container->session->internal_session)))},
	  %{&_normalize_for_tmpl($self->container->post->args)},
		%{&_normalize_for_tmpl($self->container->args->args)}
	};
}

sub all_mason_args_for_debug {
	# ritorna tutti i parametri globali
	# alcuni normalizzati
	my $self  = shift;
	return { 
		conf => $self->container->cfg,
		session =>&_normalize_for_tmpl(&_normalize_for_tmpl(&_normalize_for_tmpl($self->container->session->internal_session))),
    post 	=> &_normalize_for_tmpl($self->container->post->args) ,
		args 	=> &_normalize_for_tmpl($self->container->args->args),
		env		=> 	\%ENV
	};
}

sub _normalize_for_tmpl {
  # questa funzione prende un hashref e lo aggiusta eventualmente
  # per essere compatibile con quello che si aspetta HTML::Template
  my $params = shift;
  my %as = %{$params};
  foreach (keys %as) {
    # gestisco dei casi particolari
    if (ref($as{$_}) eq 'ARRAY' && defined($as{$_}->[0])
      && ref($as{$_}->[0]) eq '') {
      # HTML::Template si aspetta in questo caso degli hashref come
      # elementi ma se, come nel caso di form HTML con elementi con
      # name uguali, si ha un ARRAY di scalar allora lo devo gestire
      $as{"$_.array.count"} = scalar(@{$as{$_}});
      for (my $i=0;$i<$as{"$_.array.count"};$i++) {
        $as{"$_.array.$i"} = $as{$_}->[$i];
      }
      delete $as{$_};
    } elsif (ref($as{$_}) eq 'HASH') {
			# QUESTA FUNZIONE VA RESA RICORSIVA
			while (my ($k,$v) = each %{$as{$_}}) {
				$as{"$_.$k"} = $v;
			}
			delete $as{$_};
		}
  }
	return \%as;
}

1;
