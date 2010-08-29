package Puzzle::Core;

use YAML qw(LoadFile);
use Puzzle::Config;
use Puzzle::DBI;
use HTML::Mason::Request;

use Params::Validate qw(:types);
use base 'Class::Container';

__PACKAGE__->valid_params(
	cfg_path			=> { parse 	=> 'string', type => SCALAR},
	session				=> { isa 		=> 'Puzzle::Session' },
	lang_manager	=> { isa 		=> 'Puzzle::Lang::Manager' },
	cfg						=> { isa 		=> 'Puzzle::Config'} ,
	tmpl					=> { isa 		=> 'Puzzle::Template'} ,
	dbg						=> { isa 		=> 'Puzzle::Debug'} ,
	args					=> { isa 		=> 'Puzzle::Args'} ,
	post					=> { isa 		=> 'Puzzle::Post'} ,
	sendmail			=> { isa 		=> 'Puzzle::Sendmail'} ,
);

__PACKAGE__->contained_objects (
	session    		=> 'Puzzle::Session',
	lang_manager	=> 'Puzzle::Lang::Manager',
	cfg						=> 'Puzzle::Config',
	tmpl					=> 'Puzzle::Template',
	dbg						=> 'Puzzle::Debug',
	args					=> 'Puzzle::Args',
	post					=> 'Puzzle::Post',
	page					=> {class => 'Puzzle::Page', delayed => 1},
	sendmail			=> 'Puzzle::Sendmail',
);


# all new valid_params are read&write methods
use HTML::Mason::MethodMaker(
	read_only 		=> [ qw(cfg_path dbh tmpl lang_manager lang dbg args page sendmail post) ],
	read_write		=> [ 
		[ cfg 			=> __PACKAGE__->validation_spec->{'cfg'} ],
		[ session		=> __PACKAGE__->validation_spec->{'session'} ],
		[ error			=> { parse 	=> 'string', type => SCALAR} ],
	]
);

sub new {
	my $class 	= shift;
	# append parameters required for new contained objects loading them
	# from YAML config file
	my $cfgH		= LoadFile($_[1]);
	my @params	= qw(cornice base frame_bottom frame_left frame_top
										frame_right gids login description keywords db
										namespace debug cache auth_class traslation mail page);
	foreach (@params){
		push @_, ($_, $cfgH->{$_}) if (exists $cfgH->{$_});
	}
	# initialize class and their contained objects
	my $self 	= $class->SUPER::new(@_);
	$self->_init;
	return $self;
}


sub _init {
	my $self	= shift;
	
	# inizializzazione classi delayed
	my $center_class = 'Puzzle::Block';
	if ($self->cfg->page) {
		$center_class = $self->cfg->page->{center} if (exists $self->cfg->page->{center});
	}
	$self->{page} = $self->create_delayed_object('page',center_class => $center_class);
	

	$self->_autohandler_once;
}

sub _autohandler_once {
	my $self	= shift;
	$Apache::Session::Store::DBI::TableName = $self->cfg->db->{session_table};
	$Apache::Request::Redirect::LOG = 0;
	$self->{dbh} 	||= new Puzzle::DBI('dbi:mysql:' .
		$self->cfg->db->{name},$self->cfg->db->{username},$self->cfg->db->{password});
	#$self->dbh->do("SET NAMES 'latin1'") if (substr($self->dbh->get_info(  18 ),0,3)>4) ;
}

sub process_request{
	my $self	= shift;
	my $html;
	&_mason->apache_req->no_cache(1);
	$self->post->_set({$self->_mason->request_args});
	$self->session->load;
	# enable always debug for debug users
	$self->cfg->debug(1) if $self->session->user->isGid('debug');
	$self->dbg->timer_reset if $self->cfg->debug;
	# configure language object
	$self->{lang} = $self->lang_manager->get_lang_obj;
	# and send to templates
	$self->args->lang($self->lang_manager->lang_name);
	$self->_login_logout;
	$self->page->process;
	if ($self->page->center->direct_output) {
		$html	= $self->page->center->html;
	} else {
		my $args = {
			frame_bottom		=> $self->page->bottom->body,
			frame_left			=> $self->page->left->body,
			frame_top				=> $self->page->top->body,
			frame_right			=> $self->page->right->body,
			body						=> $self->page->body,
			header_client		=> $self->page->headers,
			body_attributes	=> $self->page->body_attributes,
			title						=> $self->page->title
		};
		$args->{debug} = $self->dbg->sprint if ($self->cfg->debug);
		$self->tmpl->autoDeleteHeader(0);
		$html = $self->tmpl->html($args,$self->cfg->base);
	}
	print $html;
	$self->session->save;
	#$self->dbh->disconnect unless ($self->cfg->db->{persistent_db})
}

sub _login_logout {
	my $self	= shift;
	if ($self->post->logout) {
		$self->session->auth->logout;
	} elsif ($self->post->user ne '' && $self->post->pass ne '') {
		$self->session->auth->login($self->post->user, $self->post->pass);
	}
}

sub _mason  {
	return HTML::Mason::Request->instance();
}


1;
