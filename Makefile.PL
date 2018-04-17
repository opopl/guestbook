#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use ExtUtils::MakeMaker;

WriteMakefile(
     NAME         => "GB::Root",
     VERSION      => "0.01",
    'PREREQ_PM'		=> { 
		'Log::Any'              => 0,
		'File::Spec::Functions' => 0,
		'File::Slurp'           => 0,
		'XML::LibXML'           => 0,
		'Plack'                 => 0,
		'Template'              => 0,
		'SQL::SplitStatement'   => 0,
		'DBI'                   => 0,
		'Authen::Captcha'       => 0,
		'Text::Wrap'            => 0,
	}, 
);


1;
