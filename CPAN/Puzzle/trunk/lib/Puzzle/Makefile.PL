use 5.008008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Puzzle',
    VERSION_FROM      => 'lib/Puzzle/Core.pm', # finds $VERSION
    PREREQ_PM         => {
								'YAML'				 				=> 0,
								'HTML::Mason'						=> 0,
								'Params::Validate'					=> 0,
								'Class::Container'					=> 0,
								'Apache2::Cookie'					=> 0,
								'Mail::Sendmail'					=> 0,
								'Data::Dumper'						=> 0,
								'JSON::Any'							=> 0,
								'XML::Simple'						=> 0,
								'HTML::Template::Pro::Extension'	=> 0,
								'Time::HiRes'						=> 0,
								'HTML::Entities'					=> 0,
								'File::Spec'						=> 0,
							}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Puzzle/Core.pm', # retrieve abstract from module
       AUTHOR         => 'Emiliano Bruni <info@ebruni.it>') : ()),
);
